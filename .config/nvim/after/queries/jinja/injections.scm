;; extends

; Highlight the non-template text of jinja files as yaml. This is only
; correct for yaml.jinja buffers (conda recipe/meta.yaml); if other jinja
; host languages show up, this needs to become per-filetype.
((content) @injection.content
  (#set! injection.language "yaml")
  (#set! injection.combined))
