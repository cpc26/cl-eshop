(in-package #:eshop)

;;методы для перевода старых значений в новые
(defun transform.serialize-old-product (object)
  (format nil "{\"key\":~a,\"articul\":~a,\"nameProvider\":~a,\"nameSeo\":~a,\"siteprice\":~a,\"deltaPrice\":~a,\"dateModified\":~a,\"dateCreated\":~a,\"bonuscount\":~a,\"preorder\":~a,\"newbie\":~a,\"sale\":~a,\"seoText\":~a,\"countTransit\":~a,\"countTotal\":~a,\"optgroups\":~a,\"deliveryPrice\":~a,\"parents\":~a}~%"
          (format nil "\"~a\"" (articul object))
          (encode-json-to-string (articul object))
          (format nil "\"~a\"" (object-fields.string-escaping (name object)));;name-provider
          (format nil "\"~a\"" (object-fields.string-escaping (realname object)));;name-seo
          (encode-json-to-string (siteprice object));;siteprice
          (encode-json-to-string (- (price object) (siteprice object)));;delta-price
          (encode-json-to-string (date-modified object));;date-modified
          (encode-json-to-string (date-created object));;date-created
          (encode-json-to-string (bonuscount object));;bonuscount
          (encode-json-to-string (predzakaz object));;preorder
          (encode-json-to-string (newbie object));;newbie
          (encode-json-to-string (sale object));;sale
          (format nil "\"~a\"" (object-fields.string-escaping (object-fields.string-replace-newlines (shortdescr object))));;seo-text
          (encode-json-to-string (count-transit object));;count-transit
          (encode-json-to-string (count-total object));;count-total
          (if (null (optgroups object));;optgroups
              (format nil " null")
              (format nil " [~{~a~^,~}]"
                      (mapcar #'(lambda (optgroup)
                                  (serialize optgroup))
                              (optgroups object)))
              )
          (encode-json-to-string (delivery-price object));;delivery-price
          (format nil "[ \"~a\" ]" (key (parent object))))) ;;parent


(defun transform.serialize-old-group (object)
  (format nil "{\"key\":~a,\"parents\":~a,\"name\":~a,\"active\":~a,\"order\":~a,\"ymlshow\":~a,\"pic\":~a,\"icon\":~a,\"deliveryPrice\":~a,\"seo-text\":~a,\"keyoptions\":~a}~%"
          (format nil "\"~a\"" (key object)) ;;key
          (format nil "[ \"~a\" ]" (key (parent object))) ;;parents
          (format nil "\"~a\"" (object-fields.string-escaping (name object)));;name
          (encode-json-to-string (active object));;active
          (encode-json-to-string (order object));;order
          (encode-json-to-string (ymlshow object));;ymlshow
          (format nil "\"~a\"" (object-fields.string-escaping (pic object)));;pic
          (format nil "\"~a\"" (object-fields.string-escaping (icon object)));;icon
          (encode-json-to-string (delivery-price object));;deliveryPrice
          (format nil "\"~a\"" (object-fields.string-escaping (descr object)));;seo-text
          (format nil "~{~a~}"
                  (loop :for item :in (keyoptions object) :collect
                     (format nil "{\"optgroup\":\"~a\",\"optname\":\"~a\"},"
                             (getf item :optgroup)
                             (getf item :optname))))))


(defun transform.print-to-file (text pathname)
  (with-open-file (file pathname
                        :direction :output
                        :if-exists :supersede
                        :external-format :utf-8)
    (format file text)))

(defun transform.serialize-all-products-to-file (pathname)
  (with-open-file (file pathname
                        :direction :output
                        :if-exists :supersede
                        :external-format :utf-8)
    (let ((cnt 0))
      (maphash #'(lambda (key value)
                   (declare (ignore key))
                   (when (equal (type-of value) 'product)
                     (format t "~a ~%" cnt)
                     (setf cnt (+ 1 cnt))
                     (format file "~a" (transform.serialize-old-product value))))
               *storage*))))


(defun transform.unserialize-old-products-to-new ()
  (with-open-file (file #P"/home/eviltosha/test.txt")
    (loop for line = (read-line file nil 'foo)
       until (eq line 'foo)
       do
         ;; (format t "~a~%" line)
         (let ((product (unserialize (decode-json-from-string line)
                                     (make-instance 'product))))
           (setf (gethash (key product) (storage *global-storage*)) product)
           ;; (format t "~a~%" (key product))))))
           ))))
