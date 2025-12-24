
(defstruct (colNum (:constructor make-colNum (n len)))
  (n   0 :type fixnum)
  (len 0 :type fixnum))

(defun col (i)
  (declare (type (signed-byte 64) i))
  (let ((length i))
    (declare (type fixnum length))
    (loop while (/= i 1) do
	  (if (evenp i)
	    (setf i (the (signed-byte 64)
			 (ash i -1)))     ;;; bitwise division
	    (setf i (the (signed-byte 64)
			 (+ (the (signed-byte 64) (* i 3)) 1))))
	  (if(> i length) (setf length i)))
    length))


(defun findMinIndex (arr size)
  (declare (type fixnum size))
  (let* ((minLen (colNum-len (aref arr 0)))
	 (minIndex 0))
    (declare (type fixnum minLen minIndex))
    (dotimes (i size)
      (let ((len (colNum-len (aref arr i))))
	(declare (type fixnum len))
	(when (< len minLen)
	  (setf minLen len
		minIndex i))))
    minIndex))

(defun lenSort! (arr size)
  (declare (type fixnum size))
  (dotimes (i (1- size))
    (dotimes (j (- size i 1))
      (when (< (colNum-len (aref arr j))
	       (colNum-len (aref arr (1+ j))))
	(rotatef (aref arr j) (aref arr (1+ j)))))))

(defun numSort! (arr size)
  (declare (type fixnum size))
  (dotimes (i (1- size))
    (dotimes (j (- size i 1))
      (when (< (colNum-n (aref arr j))
	       (colNum-n (aref arr (1+ j))))
	(rotatef (aref arr j) (aref arr (1+ j)))))))

(defun main ()
  (let* ((arg1 (nth 1 sb-ext:*posix-argv*))
	 (arg2 (nth 2 sb-ext:*posix-argv*))
	 (arg1 (concatenate 'string
		(subseq arg1 0 2)
		(subseq arg1 3 5)
		(subseq arg1 6 10)))
	 (arg2 (concatenate 'string
		(subseq arg2 0 2)
		(subseq arg2 3 5)
		(subseq arg2 6 10)))
	 (start  (parse-integer arg1))
	 (finish (parse-integer arg2))

	 (arr (make-array 10))
	 (size 0)
	 (minIndex 0)
	 (num 0))

    (declare (type fixnum start finish size minIndex num))

    (loop for i fixnum from start to finish do
	  (let* ((len (col i))
		 (duplicate nil))
	    (declare (type fixnum len))
		(if (> len num) (setf num len))

	    (dotimes (j size)
	      (when (= len (colNum-len (aref arr j)))
		(setf duplicate t)
		(return)))

	    (cond
	      ((and (< size 10) (not duplicate))
	       (setf (aref arr size) (make-colNum i len))
	       (incf size)
	       (setf minIndex (findMinIndex arr size)))

	      ((and (not duplicate)
		    (> len (colNum-len (aref arr minIndex))))
	       (setf (aref arr minIndex) (make-colNum i len))
	       (setf minIndex (findMinIndex arr size))))))

    (format t "~20d~%" num)))


(main)

