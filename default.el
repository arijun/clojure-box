;; Keep the splash screen away from our REPL! You have to do it in this hook
;; because initialization sets it to nil after loading site-start and default.
(add-hook 'after-init-hook
          '(lambda ()
             (setq inhibit-splash-screen t)))

;; Better buffer switching. At least it makes C-x b show the open buffers.
(require 'iswitchb)
(iswitchb-mode 1)

;; Set up clojure-mode
(let ((clojure-home (concat (file-name-directory load-file-name) "../../")))
  ;; slime tries to access this even thought it shouldn't
  (defvar package-activated-list nil)

  ;; swank-clojure assumes its autoloads run and define this before slime
  ;; is loaded.
  (defadvice slime-read-interactive-args (before add-clojure)
    ;; Unfortunately we need to construct our Clojure-launching command
    ;; at slime-launch time to reflect changes in the classpath. Slime
    ;; has no mechanism to support this, so we must resort to advice.
    (require 'assoc)
    (aput 'slime-lisp-implementations 'clojure
	  (list (swank-clojure-cmd) :init 'swank-clojure-init)))

  (add-to-list 'load-path (concat clojure-home "slime-cvs/"))
  (require 'slime)
  (slime-setup '(slime-repl))

  (add-to-list 'load-path (concat clojure-home "clojure-mode/"))
  (require 'clojure-mode)

  (add-to-list 'load-path (concat clojure-home "swank-clojure/"))
  (setq swank-clojure-jar-home (concat clojure-home "lib"))
  (require 'swank-clojure)

  ;; The user may setq this in ~/.emacs. By now it's either defined there
  ;; or in the require call above, so it's safe to add.
  (add-to-list 'swank-clojure-classpath
	       (concat clojure-home "swank-clojure/src"))

  ;; swank-clojure-project expects every dependency to live under the
  ;; project. Clojure Box users may not be up to speed with Leiningen
  ;; so we append whatever the initial classpath was onto what
  ;; swank-clojure-project thinks the classpath should be. Project
  ;; jars and dirs come first, then initial swank-clojure-classpath
  ;; stuff, so the project can always override the Clojure version or
  ;; swank or anything else.
  (defvar clojure-box-initial-classpath swank-clojure-classpath)
  (add-hook 'swank-clojure-project-hook
	    (lambda ()
	      (setq swank-clojure-classpath
		    (append swank-clojure-classpath
			    clojure-box-initial-classpath))))

  ;; Start the REPL
  (slime))
