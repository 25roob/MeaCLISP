(defparameter *wizard-nodes* '((living-room (you are in the living-room.
                                a wizard is snoring loudly on the couch.))
                               (garden (you are in a beautiful garden.
                                there is a well in front of you.))
                               (attic (you are in the attic. there
                                is a giant welding torch in the corner.))))
                                
(defparameter *wizard-edges* '((living-room (garden west door)
                                            (attic upstairs ladder))
                               (garden (living-room east door))
                               (attic (living-room downstairs ladder))))
                               
(defun dot-name (exp)
  (substitute-if #\_ (complement #'alphanumericp) (prin1-to-string exp)))
  
;(print (dot-name 'living-room))
;(print (substitute-if #\e #'digit-char-p "I'm a l33t hack3r!"))
;(print (substitute-if 0 #'oddp '(1 2 3 4 5 6 7 8)))

(defparameter *max-label-length* 30)

(defun dot-label (exp)
  (if exp
    (let ((s (write-to-string exp :pretty nil)))
      (if (> (length s) *max-label-length*)
          (concatenate 'string (subseq s 0 (- *max-label-length* 3)) "...")
          s))
    ""))
    
(defun nodes->dot (nodes)
  (mapc (lambda (node)
          (fresh-line)
          (princ (dot-name (car node)))
          (princ "[label=\"")
          (princ (dot-label node))
          (princ "\"];"))
        nodes))
        
;(nodes->dot *wizard-nodes*)

(defun edges->dot (edges)
  (mapc (lambda (node)
          (mapc (lambda (edge)
                  (fresh-line)
                  (princ (dot-name (car node)))
                  (princ "->")
                  (princ (dot-name (car edge)))
                  (princ "[label=\"")
                  (princ (dot-label (cdr edge)))
                  (princ "\"];"))
                (cdr node)))
        edges))
        
;(edges->dot *wizard-edges*)

(defun graph->dot (nodes edges)
  (princ "digraph{")
  (nodes->dot nodes)
  (edges->dot edges)
   (princ "}"))
   
;(graph->dot *wizard-nodes* *wizard-edges*)

(defun dot->png (fname thunk)
 (with-open-file (*standard-output*
                   fname
                   :direction :output
                   :if-exists :supersede)
    (funcall thunk))
 (ext:shell (concatenate 'string "dot -Tpng -O " fname)))
 
(with-open-file (my-stream
                 "testfile.txt"
                 :direction :output
                 :if-exists :supersede)
    (princ "Hello File!" my-stream))
    
(defun graph->png (fname nodes edges)
  (dot->png fname
        (lambda ()
          (graph->dot nodes edges))))
          
;(graph->png "wizard.dot" *wizard-nodes* *wizard-edges*)

;undirected graph ahead

(defun uedges->dot (edges)
  (maplist (lambda (lst)
             (mapc (lambda (edge)
                     (unless (assoc (car edge) (cdr lst))
                       (fresh-line)
                       (princ (dot-name (caar lst)))
                       (princ "--")
                       (princ (dot-name (car edge)))
                       (princ "[label=\"")
                       (princ (dot-label (cdr edge)))
                       (princ "\"];")))
                    (cdar lst)))
            edges))
            
(defun ugraph->dot (nodes edges)
  (princ "graph{")
  (nodes->dot nodes)
  (uedges->dot edges)
  (princ "}"))
  
(defun ugraph->png (fname nodes edges)
  (dot->png fname
            (lambda ()
              (ugraph->dot nodes edges))))
              
;(mapcar #'print '(a b c))
;(maplist #'print '(a b c))

(ugraph->dot *wizard-nodes* *wizard-edges*)
;(ugraph->png "wizard.dot" *wizard-nodes* *wizard-edges*)