module Constants
  # NOTE: メールアドレスのバリデーションは、input type="email">と同じとした。
  # https://developer.mozilla.org/ja/docs/Web/HTML/Element/input/email
  # https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
  EMAIL_REGEXP = /\A[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/.freeze
end
