;;; tsv.scm - Module for Lepton EDA
;;; Read a tab separated value file.
;;;
;;; Copyright (C)  2019 John P. Doty
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

(define-module (noqsi tsv))

(use-modules (ice-9 rdelim))

;; Assemble the places to look for data

(define (data-dirs)
	(append 
		((@ (geda os) sys-data-dirs))
		(list ((@ (geda os) user-data-dir)))
		'(".")
	)
)

;; Make a list of potential file names
;; the argument is the basename without ".tsv"

(define (tsv-file-names name)
	(map 
		(lambda (dir) 
			(string-append 
				dir 
				file-name-separator-string 
				name 
				".tsv"
			)
		)
		(data-dirs)
	)
)

;; Identify the data files that exist

(define (tsv-files name)
	(filter file-exists? (tsv-file-names name))
)

;; make a list of the lines from a port

(define (read-lines port)
	(let ((l (read-line port)))
		(if (eof-object? l)
			'()
			(cons l (read-lines port))
		)
	)
)

;; given a file name, get a list of lines

(define (read-file name)
	(call-with-input-file name read-lines)
)

;; get all the lines from all the files

(define (read-files name)
	(apply append (map read-file (tsv-files name)))
)

;; regular expressions for ignoring blank lines and comments

(define comment (make-regexp "^#"))
(define blank (make-regexp "^ *$"))

;; predicate for data line, not blank or comment

(define (data-line? l) 
	(not (or 
		(regexp-exec comment l)
		(regexp-exec blank l)
	))
)

;; split a data line into fields

(define (tsv-fields line) (string-split line #\tab))

;; get a list of lists of fields from all files

(define (tsv-data name)
	(map tsv-fields 
		(filter data-line? (read-files name))
	)
)

(export tsv-data)
