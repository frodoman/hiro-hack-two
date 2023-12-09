(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-constant ERR_UNAUTHORIZED (err u3000))
(define-constant ERR_UNKNOWN_PARAMETER (err u3001))

(define-map parameters (string-ascii 34) uint)

(map-set parameters "proposal-duration" u1440) ;; ~10 days based on a ~10 minute block time.

;; ------------------------
;; Public functions 
;; ------------------------
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED))
)

(define-public (propose (proposal <proposal-trait>) (title (string-ascii 50)) (description (string-utf8 500)))
  (let 

    (
      (end-block (unwrap! (get-parameter "proposal-duration") ERR_UNKNOWN_PARAMETER))
    )

    (contract-call? .proposal-voting add-proposal
      proposal
      {
        start-block-height: block-height, ;; TODO: Should we use custom block-height?
        end-block-height: (+ block-height end-block),
        proposer: tx-sender,
        title: title,
        description: description
      }
    )

  )
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

;; ------------------------
;; Read only functions 
;; ------------------------
(define-read-only (get-parameter (parameter (string-ascii 34)))
  (map-get? parameters parameter)
)