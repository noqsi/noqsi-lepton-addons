;;; Unit test for pincount package
;;; Copyright (C)  2020 John P. Doty
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

(use-modules (noqsi pincount))
(use-modules (srfi srfi-1))


(define (test unused-filename)
	(or
		(all-true? (map do-test tests))
		(primitive-exit 1)
	)
)

; Is there a less obscure way to apply and to a list?

(define (all-true? list) (every (lambda (x) x) list))

(define (do-test test)
	(or 
		(equal? ((car test) (cadr test)) (caddr test))
		(begin
			(format (current-error-port)
				"(~A ~A) yielded ~A, should be ~A\n"
				(car test) 
				(cadr test)
				((car test) (cadr test))
				(caddr test)
			)
			#f
		)
	)
)

(define tests `(
(,get-package-pincount "Q1" 3)
(,pins-from-footprint "Q1" #f)
(,get-package-pincount "Q2" 3)
(,pins-from-footprint "Q2" 3)
(,get-package-pincount "Q3" 4)
(,pins-from-footprint "Q3" 4)
(,get-package-pincount "Q4" 5)
(,pins-from-footprint "Q4" 5)
(,get-package-pincount "J1" 9)
(,pins-from-footprint "J1" 9)
))
