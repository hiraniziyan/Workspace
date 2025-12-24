(declaim (optimize (speed 3) (safety 0) (debug 0)))

(defstruct (colNum (:constructor make-colNum (n len)))
  (n   0 :type fixnum)
  (len 0 :type fixnum))

(declaim (inline rec-col-32))
(defun rec-col-32 (i)
  (declare (type (unsigned-byte 32) i))
  (if (= i 1)
    0
    (if (= (logand i 1) 0)
      (1+ (rec-col-32 (the (unsigned-byte 32) (ash i -1))))
      (1+ (rec-col-32 (the (unsigned-byte 32) (+ (* i 3) 1)))))))

(declaim (inline rec-col-64))
(defun rec-col-64 (i)
  (declare (type (signed-byte 64) i))
  (if (= i 1)
    0
    (if (= (logand i 1) 0)
      (1+ (rec-col-64 (ash i -1)))
      (1+ (rec-col-64 (+ (* i 3) 1))))))

(declaim (inline rec-col))
(defun rec-col (i)
  (if (or (>= i 1850000000)
	  (and (>= i 1410000000)
	       (<= i 1420000000)))
    (rec-col-64 i)
    (rec-col-32 (the (unsigned-byte 32) i))))


(defun findMinIndex (arr size)
  (declare (type fixnum size))
  (let* ((minLen (colNum-len (aref arr 0)))
	 (minIndex 0))
    (declare (type fixnum minLen minIndex))
    (dotimes (i size)
      (let ((len (colNum-len (aref arr i))))
	(when (< len minLen)
	  (setf minLen len
		minIndex i))))
    minIndex))

(defun lenSort! (arr size)
  (dotimes (i (1- size))
    (dotimes (j (- size i 1))
      (when (< (colNum-len (aref arr j))
	       (colNum-len (aref arr (1+ j))))
	(rotatef (aref arr j) (aref arr (1+ j)))))))

(defun numSort! (arr size)
  (dotimes (i (1- size))
    (dotimes (j (- size i 1))
      (when (< (colNum-n (aref arr j))
	       (colNum-n (aref arr (1+ j))))
	(rotatef (aref arr j) (aref arr (1+ j)))))))

(defun main ()
  (let* ((arg1 (nth 1 sb-ext:*posix-argv*))
	 (arg2 (nth 2 sb-ext:*posix-argv*))
	 (start  (parse-integer arg1))
	 (finish (parse-integer arg2))

	 (arr (make-array 10))
	 (size 0)
	 (minIndex 0))

    (loop for i from start to finish do
	  (let* ((len (rec-col i))
		 (duplicate nil))

	    ;; check duplicates
	    (dotimes (j size)
	      (when (= len (colNum-len (aref arr j)))
		(setf duplicate t)
		(return)))

	    ;; insert
	    (cond
	      ((and (< size 10) (not duplicate))
	       (setf (aref arr size) (make-colNum i len))
	       (incf size)
	       (setf minIndex (findMinIndex arr size)))

	      ((and (not duplicate)
		    (> len (colNum-len (aref arr minIndex))))
	       (setf (aref arr minIndex) (make-colNum i len))
	       (setf minIndex (findMinIndex arr size))))))

    (lenSort! arr size)
    (format t "Sorted based on sequence length~%")
    (dotimes (k size)
      (let ((c (aref arr k)))
	(format t "~20d~20d~%" (colNum-n c) (colNum-len c))))

    (format t "Sorted based on integer size~%")
    (numSort! arr size)
    (dotimes (k size)
      (let ((c (aref arr k)))
	(format t "~20d~20d~%" (colNum-n c) (colNum-len c))))))

(main)
