;;; gEDA - GPL Electronic Design Automation
;;; gnet-check-pincount.scm - check that each package in a project has the correct
;;; number of pins.
;;;
;;; Copyright (C)  2015, 2020 John P. Doty
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
(use-modules (netlist schematic)
             (netlist schematic toplevel))


;; lepton-netlist back end. The actual logic is in the module.
;;
(define (check-pincount unused-filename)
	(or
		(all-true?(map check-package-pincount 
			(schematic-package-names (toplevel-schematic))
		))
		(primitive-exit 1)
	)
)

; Is there a less obscure way to apply and to a list?

(define (all-true? list) (every (lambda (x) x) list))
