#lang racket

(require 
 ;; Data structures
 "asm-base.rkt"
 ;; Helper functions
 "asm-support.rkt"
 ;; Passes
 "pass-file-to-los.rkt"
 "pass-parse.rkt"
 "pass-attach-instruction-locations.rkt"
 ;; For pretty printing.
 racket/pretty)

(define (driver file)
  (each 
   ;; First convert to a list of strings
   [list-of-strings (file->list-of-strings file)]
   ;; Then parse
   [parsed (parse list-of-strings)]
   ;; Now, attach instruction locations
   [numbered (attach-instruction-locations parsed 0)]
   ;; Add labels
   [x1 (add-labels-to-table numbered)]
   ;; Add memory locations
   [x2 (add-memory-addresses-to-table numbered)]
   ;; Assign the addresses
   [assigned (assign-addresses numbered)]
   ;; Filter out the labels that remain
   [no-labels (filter (λ (i) (not (label? i))) assigned)]
   ;; Convert structures to binary
   [zeroones (map structure->binary no-labels)]
   ;; Write the file
   [x3 (write-file! file res)]
   [final numbered]))