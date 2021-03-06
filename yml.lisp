(in-package #:eshop)

;; Группы представляют собой лес для YML нам нужны не только сами
;; группы маркированные для выгрузки но и их родители
;; На самом деле нам нужно минимальные оставные деревья,
;; но будем выгружать полные деревья исключая только листья, если это нужно


(defparameter *yml-group-ids* (make-hash-table :test #'equal))

(defun yml-groups ()
  "Строим *yml-group-ids*"
  (let ((current-id 1))
    (clrhash *yml-group-ids*)
    (maphash #'(lambda(k g)
                 (when (equal (type-of g) 'group)
                   ;; Если группа имеет дочерние группы ИЛИ yml-show == true
                   (when (or
                          (not (null (childs g)))
                          (ymlshow g))
                     ;; Кладем ее в *yml-group-ids* и увеличиваем current-id
                     (setf (gethash k *yml-group-ids*) current-id )
                     (incf current-id))))
             *storage*)
    *yml-group-ids*))


;; (maphash #'(lambda (k v)
;;              (print (list k v)))
;;          (yml-groups))

(defun yml-page ()
  (setf (hunchentoot:content-type*) "application/xml; charset=utf-8")
  (yml:xml (list :datetime (get-date-time)
                 :marketname "ЦиFры 320-8080"
                 :marketcompany "ЦиFры 320-8080"
                 :marketurl "http://www.320-8080.ru/"
                 :categoryes
                 (loop
                    :for key
                    :being :the hash-key
                    :using (hash-value id)
                    :in (yml-groups)
                    :when (equal 'group (type-of (gethash key *storage*)))
                    :collect (list :id id
                                   :name (name (gethash key *storage*))
                                   :parent (if (null (parent (gethash key *storage*)))
                                               0 ;; если это вершина дерева
                                               (let* ((parent (parent (gethash key *storage*)))
                                                      (parent-key (key parent))
                                                      (num-key (gethash parent-key *yml-group-ids*)))
                                                 num-key))))
                 :offers (format nil "~{~a~}"
                                 (loop
                                    :for product
                                    :being :the hash-values
                                    :in *storage*
                                    ;;продукт должен находиться в группе маркированной как ymlshow
                                    ;;быть активным и иметь не нулевую цену
                                    :when (and (equal 'product (type-of product))
                                               (not (null (parent product)))
                                               (ymlshow (parent product))
                                               (active product)
                                               (not (null (price product)))
                                               (> (price product) 0)
                                               ;;для селективного исключения товаров по значению специальной опции
                                               (let ((yml-show))
                                                 (with-option product "Secret" "UML"
                                                              (setf yml-show (value option)))
                                                 (if (and (not (null yml-show))
                                                          (string= "No"
                                                                   (stripper yml-show)))
                                                     nil
                                                     t)))
                                    :collect (yml:offer (list :articul (articul product)
                                                              :price (siteprice product)
                                                              :category (gethash
                                                                         (key (parent product))
                                                                         *yml-group-ids*)
                                                              :picture  (let ((pics (get-pics
                                                                                     (articul product))))
                                                                          (if (null pics)
                                                                              nil
                                                                              (encode-uri (car pics))))
                                                              :name   (let ((yml-name))
                                                                        (with-option product "Secret" "Yandex"
                                                                                     (setf yml-name (value option)))
                                                                        (if (or (null yml-name)
                                                                                (string= ""
                                                                                         (stripper yml-name))
                                                                                (string= "No"
                                                                                         (stripper yml-name)))
                                                                            (name product)
                                                                            yml-name))
                                                              :description (if (string= "NIL"
                                                                                        (descr product))
                                                                               nil
                                                                               (descr product))
                                                              )))))))


(defun yml-name-test (product)
  (let ((yml-name))
    (with-option product "Secret" "Yandex"
                 (setf yml-name (value option)))
    (if (or (null yml-name)
            (string= ""
                     (stripper yml-name))
            (string= "No"
                     (stripper yml-name)))
        (name product)
        yml-name)))

(defun yml-show-test (product)
  (let ((yml-show))
    (with-option product "Secret" "UML"
                 (setf yml-show (value option)))
    (if (and (not (null yml-show))
             (string= "No"
                      (stripper yml-show)))
        nil
        t)))

;; (length (get-recursive-products (gethash "noutbuki" *storage*)))
;; (length (remove-if-not #'yml-show-test (get-recursive-products (gethash "noutbuki" *storage*))))


;; На самом деле нам нужно минимальные оставные деревья,
;; но будем выгружать полные деревья исключая только листья, если это нужно


(defparameter *yml-group-ids* (make-hash-table :test #'equal))

(defun yml-groups ()
  "Строим *yml-group-ids*"
  (let ((current-id 1))
    (clrhash *yml-group-ids*)
    (maphash #'(lambda(k g)
                 (when (equal (type-of g) 'group)
                   ;; Если группа имеет дочерние группы ИЛИ yml-show == true
                   (when (or
                          (not (null (childs g)))
                          (ymlshow g))
                     ;; Кладем ее в *yml-group-ids* и увеличиваем current-id
                     (setf (gethash k *yml-group-ids*) current-id )
                     (incf current-id))))
             *storage*)
    *yml-group-ids*))


;; (maphash #'(lambda (k v)
;;              (print (list k v)))
;;          (yml-groups))

(defun yml-page ()
  (setf (hunchentoot:content-type*) "application/xml; charset=utf-8")
  (yml:xml (list :datetime (get-date-time)
                 :marketname "ЦиFры 320-8080"
                 :marketcompany "ЦиFры 320-8080"
                 :marketurl "http://www.320-8080.ru/"
                 :categoryes
                 (loop
                    :for key
                    :being :the hash-key
                    :using (hash-value id)
                    :in (yml-groups)
                    :when (equal 'group (type-of (gethash key *storage*)))
                    :collect (list :id id
                                   :name (name (gethash key *storage*))
                                   :parent (if (null (parent (gethash key *storage*)))
                                               0 ;; если это вершина дерева
                                               (let* ((parent (parent (gethash key *storage*)))
                                                      (parent-key (key parent))
                                                      (num-key (gethash parent-key *yml-group-ids*)))
                                                 num-key))))
                 :offers (format nil "~{~a~}"
                                 (loop
                                    :for product
                                    :being :the hash-values
                                    :in *storage*
                                    ;;продукт должен находиться в группе маркированной как ymlshow
                                    ;;быть активным и иметь не нулевую цену
                                    :when (and (equal 'product (type-of product))
                                               (not (null (parent product)))
                                               (ymlshow (parent product))
                                               (active product)
                                               (not (null (price product)))
                                               (> (price product) 0)
                                               ;;для селективного исключения товаров по значению специальной опции
                                               (let ((yml-show))
                                                 (with-option product "Secret" "YML"
                                                              (setf yml-show (value option)))
                                                 (if (and (not (null yml-show))
                                                          (string= "No"
                                                                   (stripper yml-show)))
                                                     nil
                                                     t)))
                                    :collect (yml:offer (list :articul (articul product)
                                                              :price (siteprice product)
                                                              :category (gethash
                                                                         (key (parent product))
                                                                         *yml-group-ids*)
                                                              :picture  (let ((pics (get-pics
                                                                                     (articul product))))
                                                                          (if (null pics)
                                                                              nil
                                                                              (encode-uri (car pics))))
                                                              :name   (let ((yml-name))
                                                                        (with-option product "Secret" "Yandex"
                                                                                     (setf yml-name (value option)))
                                                                        (if (or (null yml-name)
                                                                                (string= ""
                                                                                         (stripper yml-name))
                                                                                (string= "No"
                                                                                         (stripper yml-name)))
                                                                            (name product)
                                                                            yml-name))
                                                              :description (if (string= "NIL"
                                                                                        (descr product))
                                                                               nil
                                                                               (descr product))
                                                              )))))))


/**
 *
 *
 **/
(defun yml-page-for-parser ()
  (setf (hunchentoot:content-type*) "application/xml; charset=utf-8")
  (yml:xml (list :datetime (get-date-time)
                 :marketname "ЦиFры 320-8080"
                 :marketcompany "ЦиFры 320-8080"
                 :marketurl "http://www.320-8080.ru/"
                 :categoryes
                 (loop
                    :for key
                    :being :the hash-key
                    :using (hash-value id)
                    :in (yml-groups)
                    :when (equal 'group (type-of (gethash key *storage*)))
                    :collect (list :id id
                                   :name (name (gethash key *storage*))
                                   :parent (if (null (parent (gethash key *storage*)))
                                               0 ;; если это вершина дерева
                                               (let* ((parent (parent (gethash key *storage*)))
                                                      (parent-key (key parent))
                                                      (num-key (gethash parent-key *yml-group-ids*)))
                                                 num-key))))
                 :offers (format nil "~{~a~}"
                                 (loop
                                    :for product
                                    :being :the hash-values
                                    :in *storage*
                                    ;;продукт должен находиться в группе маркированной как ymlshow
                                    ;;быть активным и иметь не нулевую цену
                                    :when (and (equal 'product (type-of product))
                                               (not (null (parent product)))
                                               (ymlshow (parent product))
                                               (active product)
                                               (not (null (price product)))
                                               (> (price product) 0)
                                               ;;для селективного исключения товаров по значению специальной опции
                                               (let ((yml-show))
                                                 (with-option product "Secret" "YML"
                                                              (setf yml-show (value option)))
                                                 (if (and (not (null yml-show))
                                                          (string= "No"
                                                                   (stripper yml-show)))
                                                     nil
                                                     t)))
                                    :collect (yml:offer (list :articul (articul product)
                                                              :price (siteprice product)
                                                              :category (gethash
                                                                         (key (parent product))
                                                                         *yml-group-ids*)
                                                              :picture  (let ((pics (get-pics
                                                                                     (articul product))))
                                                                          (if (null pics)
                                                                              nil
                                                                              (encode-uri (car pics))))
                                                              :name   (let ((yml-name)
                                                                            (parser-name))
                                                                        (with-option product "Secret" "Yandex"
                                                                                     (setf yml-name (value option)))
                                                                        (with-option product "Secret" "Parser"
                                                                                     (setf parser-name (value option)))
                                                                        (if (or (null parser-name)
                                                                                (string= "" parser-name))
                                                                            (if (or (null yml-name)
                                                                                    (string= ""
                                                                                             (stripper yml-name))
                                                                                    (string= "No"
                                                                                             (stripper yml-name)))
                                                                                (name product)
                                                                                yml-name)
                                                                            parser-name))
                                                              :description (if (string= "NIL"
                                                                                        (descr product))
                                                                               nil
                                                                               (descr product))
                                                              )))))))


(defun yml-name-test (product)
  (let ((yml-name))
    (with-option product "Secret" "Yandex"
                 (setf yml-name (value option)))
    (if (or (null yml-name)
            (string= ""
                     (stripper yml-name))
            (string= "No"
                     (stripper yml-name)))
        (name product)
        yml-name)))

(defun yml-show-test (product)
  (let ((yml-show))
    (with-option product "Secret" "UML"
                 (setf yml-show (value option)))
    (if (and (not (null yml-show))
             (string= "No"
                      (stripper yml-show)))
        nil
        t)))

;; (length (get-recursive-products (gethash "noutbuki" *storage*)))
;; (length (remove-if-not #'yml-show-test (get-recursive-products (gethash "noutbuki" *storage*))))

(defun make-yml-categoryes()
  (loop
     :for key
     :being :the hash-key
     :using (hash-value id)
     :in (yml-groups)
     :when (equal 'group (type-of (gethash key *storage*)))
     :collect (list :id id
                    :name (name (gethash key *storage*))
                    :parent (if (null (parent (gethash key *storage*)))
                                0 ;; если это вершина дерева
                                (let* ((parent (parent (gethash key *storage*)))
                                       (parent-key (key parent))
                                       (num-key (gethash parent-key *yml-group-ids*)))
                                  num-key)))))
(defun make-yml-offers()
   (loop
     :for product
     :being :the hash-values
     :in *storage*
     ;;продукт должен находиться в группе маркированной как ymlshow
     ;;быть активным и иметь не нулевую цену
     :when (and (equal 'product (type-of product))
                (not (null (parent product)))
                (ymlshow (parent product))
                (active product)
                (not (null (price product)))
                (> (price product) 0)
                ;;для селективного исключения товаров по значению специальной опции
                (let ((yml-show))
                  (with-option product "Secret" "UML"
                               (setf yml-show (value option)))
                  (if (and (not (null yml-show))
                           (string= "No"
                                    (stripper yml-show)))
                      nil
                      t)))
     :collect
     (yml:offer (list :articul (articul product)
                      :price (siteprice product)
                      :category (gethash
                                 (key (parent product))
                                 *yml-group-ids*)
                      :picture  (let ((pics (get-pics
                                             (articul product))))
                                  (if (null pics)
                                      nil
                                      (encode-uri (car pics))))
                      :name   (let ((yml-name))
                                (with-option product "Secret" "Yandex"
                                             (setf yml-name (value option)))
                                (if (or (null yml-name)
                                        (string= ""
                                                 (stripper yml-name))
                                        (string= "No"
                                                 (stripper yml-name)))
                                    (name product)
                                    yml-name))
                      :description (if (string= "NIL"
                                                (descr product))
                                       nil
                                       (descr product))
                      ))))


(defun make-yml-data()
  (yml:xml
        (list :datetime (get-date-time)
              :marketname "ЦиFры 320-8080"
              :marketcompany "ЦиFры 320-8080"
              :marketurl "http://www.320-8080.ru/"
              :categoryes (make-yml-categoryes)
              :offers (format nil "~{~a~}" (make-yml-offers)))))


(defun create-yml-file ()
  (let ((filename (format nil "~a/yml.xml" *path-to-conf*)))
    (with-open-file
        (stream filename :direction :output :if-exists :supersede)
      (format stream "~a" (make-yml-data)))))


;; (create-report "xls/products.csv" #'write-products-report)
