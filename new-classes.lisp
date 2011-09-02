(in-package #:eshop)

;;набор функций для показа и изменения различных типов полей в админке

;;string - универсальный тип, так же используется как undefined
(defun new-classes.view-string-field (value name disabled)
  (soy.class_forms:string-field
   (list :name name :disabled disabled :value value)))

(defun new-classes.string-field-get-data (string)
  string)

;;int
(defun new-classes.view-int-field (value name disabled)
  (new-classes.view-string-field (format nil "~a" value) name disabled))

(defun new-classes.int-field-get-data (string)
  (parse-integer string))


;;textedit, онлайновый WYSIWYG редактор текста
(defun new-classes.view-textedit-field (value name disabled)
  (if disabled
      (new-classes.view-string-field value name disabled)
      (soy.class_forms:texteditor
       (list :name name :value value))))

(defun new-classes.textedit-field-get-data (string)
  string)


;;time, человекопонятное время
(defun new-classes.view-time-field (value name disabled)
  (new-classes.view-string-field (time.decode-date-time value) name disabled))

(defun new-classes.time-field-get-data (string)
  string)


;;bool
(defun new-classes.view-bool-field (value name disabled)
  (soy.class_forms:bool-field
   (list :name name :checked value :disabled disabled)))

(defun new-classes.bool-field-get-data (string)
  (string= string "T"))


;;group, список групп, генерируется из списка с проставленными уровнями глубины
(defun new-classes.view-group-field (value name disabled)
  (let ((leveled-groups (storage.get-groups-leveled-tree)))
    (soy.class_forms:group-form
     (list :name name :disabled disabled
           :grouplist (mapcar #'(lambda (group-and-level)
                                  (let ((group (car group-and-level))
                                        (level (cdr group-and-level)))
                                    (list :hashkey (key group)
                                          :selected (eq value group)
                                          :name (name group)
                                          :indent (let ((indent ""))
                                                    (loop for x from 1 to level
                                                       do (setf indent (concatenate 'string indent "---")))
                                                    indent))))
                              leveled-groups)))))

(defun new-classes.group-field-get-data (string)
  (gethash string (storage *global-storage*)))





;;макрос для создания класса по списку параметров
(defmacro new-classes.make-class (name class-fields)
  `(defclass ,name ()
     ,(mapcar #'(lambda (field)
                  `(,(getf field :name)
                     :initarg ,(getf field :initarg)
                     :initform ,(getf field :initform)
                     :accessor ,(getf field :accessor)))
              class-fields)))


;;макрос для создания методов просмотра по списку параметров
(defmacro new-classes.make-view-method (name class-fields)
  `(defmethod new-classes.make-fields ((object ,name))
     ,(cons
       `list
       (mapcar #'(lambda (field)
                   `(,(intern (string-upcase
                               (format nil "new-classes.view-~a-field" (getf field :type))))
                                      (,(getf field :name)  object)
                                      ,(format nil "~a" (getf field :name))
                                      ,(getf field :disabled)))
               class-fields))))


;;макрос для создания методов редактирования
(defmacro new-classes.make-edit-method (name class-fields)
  `(defmethod new-classes.edit-fields ((object ,name) post-data-plist)
     ,(cons
       `progn
       (mapcar #'(lambda (field)
                   (when (not (getf field :disabled))
                     `(setf (,(getf field :name) object)
                            (,(intern (string-upcase
                                       (format nil "new-classes.~a-field-get-data" (getf field :type))))
                              (decode-uri (getf post-data-plist ,(intern (string-upcase (format nil "~a" (getf field :name))) :keyword)))))))
               class-fields))))


(defun new-classes.make-class-and-methods (name list-fields)
  (eval `(new-classes.make-class ,name ,list-fields))
  (eval `(new-classes.make-view-method ,name ,list-fields))
  (eval `(new-classes.make-edit-method ,name ,list-fields)))

