;;; pincount.scm - Module for Lepton EDA
;;; Determine the pin coount of a package
;;;
;;; Copyright (C)  2019, 2020 John P. Doty
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

(define-module (noqsi pincount))

(use-modules (srfi srfi-1))
(use-modules (ice-9 regex))
(use-modules (ice-9 format))
(use-modules (noqsi tsv))
(use-modules (netlist))
	     
(define counts (make-hash-table))

(define (table-error message entry)
	(format (current-error-port) "~A\n~S\n" message entry)
	(primitive-exit 1)
)

(define num (make-regexp "^[0-9]+$"))

(define (enter-pincount-for-footprint entry)
	
	(if (< (length entry) 2)
		(table-error 
			"A pincount table entry needs two fields."
			entry
		)
	)
	
	(if 	(not (or 
			(regexp-exec num (cadr entry))
			(equal? (cadr entry) "*")
		))
		(table-error 
			"Pincount must be number or \"*\"."
			entry
		)
	)
	
	(hash-set! 
		counts 
		(car entry) 
		(or (string->number (cadr entry)) (cadr entry))
	)
)

(for-each enter-pincount-for-footprint (tsv-data "pincounts"))

;; Extract the pin count from the footprint with the prefix string removed.
(define pin-count-regexp (make-regexp "[0-9]*"))
(define (get-count-from-attrib pre attrib)
	(let ((s (match:substring (regexp-exec pin-count-regexp attrib (string-length pre)))))
		(if (string-null? s) #f (string->number s))))

;; Look up the prefix and use it to extract the count as a character string.
;; Recursively trims the footprint name f until it matches a prefix.
;; Returns (prefix.count).
;; Count could be "*".
;; Return #f on failure.
(define (prefix-pins f)
	(and
		f 
		(not (string-null? f))
		(let
			((pc (hash-ref counts f)))
			(if pc 
				(cons f pc)
				(prefix-pins (string-drop-right f 1))
			)
		)
	)
)

(define (pins-from-footprint f)
	(let ((pc (prefix-pins f)))
		(and
			pc
			(if (equal? (cdr pc) "*")
				(get-count-from-attrib (car pc) f)
				(cdr pc)
			)
		)
	)
)

; Stole the following from netlist.scm
;;; Default resolver: Returns the first valid (non-#F) value from
;;; VALUES, or #F, if there is no valid attribute value. If any
;;; other valid value in the list is different, yields a warning
;;; reporting REFDES of affected symbol instances and attribute
;;; NAME.
(define (unique-attribute refdes name values)
  (let ((values (filter-map identity values)))
    (and (not (null? values))
         (let ((value (car values)))
           (or (every (lambda (x) (equal? x value)) values)
               (format (current-error-port)  "\
Possible attribute conflict for refdes: ~A
name: ~A
values: ~A
" refdes name values))
           value))))


(define (get-attribute refdes name)
	(unique-attribute refdes name 
		(get-all-package-attributes refdes name)))

(define (get-numeric-attribute refdes name)
	(let ((value (get-attribute refdes name)))
		(and 
			value
			(if (regexp-exec num value)
				(string->number value)
				(numeric-warning refdes name value)
			)
		)
	)
)

(define (numeric-warning refdes name value)
	(format (current-error-port)
		"For ~A ~A = ~A is not numeric\n"
		refdes name value
	)
	#f
)
		 

;; First try to get the pincount from a pins= attribute.
;; If that fails, try to get it from the footprint.
;; If that fails, resort to counting connections.
(define (get-package-pincount p)
	(or 
		(get-numeric-attribute p "pins") 
		(pins-from-footprint (get-attribute p "footprint"))
		(length (get-pins p))
	)
)


(define (check-package-pincount p)
	(let* 	(
			(nu (get-numeric-attribute p "pins-used"))
			(n (get-numeric-attribute p "pins"))
			(fp (get-attribute p "footprint"))
			(f (pins-from-footprint fp))
			(c (length (get-pins p)))
		)
		(if nu
			; then pins-used= rules
			(if (not (equal? nu c))
				(pins!=used p nu c)
				#t
			)
			(if n
				; then pins= rules
				(if (not (equal? n c))
					(pins!=count p n c)
					#t
				)
				; else try using footprint
				(if f 
					; then we have a footprint to use
					(if (not (equal? f c))
						(footprint!=count p f c fp)
						#t
					)
				; else have nothing to use
					(pincount-unknown p)
				)
			)
		)
	)
)

(define (pincount-unknown p)
	(format (current-error-port) "\nCannot determine expected pin count for ~A.\n" p)
	(format (current-error-port) "Either add a pins= attribute, a pins-used= attribute,")
	(format (current-error-port) " or use a standard gEDA footprint.\n")
	#f
)

(define (pins!=count p n c)
	(format (current-error-port) "\n~A has ~A pins, but has attribute pins=~A.\n"
		p c n
	)
	#f
)

(define (pins!=used p n c)
	(format (current-error-port) "\n~A has ~A pins, but has attribute pins-used=~A.\n"
		p c n
	)
	#f
)

(define (footprint!=count p f c fp)
	(format (current-error-port) "\n~A has ~A pins, but its footprint ~A has ~A.\n"
		p c fp f
	)
	#f
)

(export get-package-pincount 
	enter-pincount-for-footprint 
	pins-from-footprint
	get-numeric-attribute
	check-package-pincount)
