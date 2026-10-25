# frozen_string_literal: true
#
# KI-Transparenz / EU AI Act (Art. 50)
#
# Blendet oben in einem Beitrag eine sichtbare Kennzeichnungs-Box ein, wenn im
# Front-Matter `ai: full` (vollstaendig KI-generiert) oder `ai: partial`
# (teilweise mit KI bearbeitet) gesetzt ist. Ohne `ai:` passiert nichts.
#
# Texte, Icons und der "Mehr erfahren"-Link stammen aus `_data/ai_disclosure.yml`.
# Es wird KEINE Theme-Datei ueberschrieben – die Box wird per Hook an den Anfang
# des Beitragsinhalts gestellt und erscheint dadurch oben in `<div class="content">`.

module AIDisclosure
  ACCENT = { 'full' => 'info', 'partial' => 'warning' }.freeze

  # Front-Matter-Wert auf 'full' | 'partial' | nil normalisieren.
  def self.normalize(value)
    return 'full' if value == true

    v = value.to_s.strip.downcase
    ACCENT.key?(v) ? v : nil
  end

  # Baut die Hinweis-Box. Farben nutzen Chirpy-CSS-Variablen und sind daher
  # automatisch hell-/dunkel-adaptiv.
  #
  # WICHTIG: `<a ...><img ...></a>` steht bewusst OHNE Leerzeichen an den
  # Tag-Grenzen. So erkennt Chirpys `refactor-content.html` das Bild als bereits
  # verlinkt und umschliesst es NICHT mit einem Lightbox-Popup.
  def self.box_html(type, cfg, baseurl)
    tcfg   = cfg[type] || {}
    accent = ACCENT[type]
    page   = "#{baseurl}#{cfg['page']}"
    icon   = "#{baseurl}#{tcfg['icon']}"
    alt    = tcfg['alt'].to_s
    label  = tcfg['label'].to_s
    more   = (cfg['more_text'] || 'Mehr erfahren').to_s

    icon_link =
      %(<a href="#{page}" aria-label="#{alt}" ) +
      %(style="flex:0 0 auto;display:inline-flex;align-items:center;background:#fff;) +
      %(border-radius:.4rem;padding:.25rem .4rem;line-height:0;">) +
      %(<img src="#{icon}" alt="#{alt}" style="height:22px;width:auto;display:block;"></a>)

    text =
      %(<span style="min-width:0;">#{label} ) +
      %(<a href="#{page}" style="color:var(--prompt-#{accent}-icon-color);white-space:nowrap;">#{more}</a></span>)

    %(<div class="ai-disclosure" role="note" ) +
      %(style="display:flex;align-items:center;gap:.7rem;margin:0 0 1.5rem;padding:.6rem .8rem;) +
      %(border-radius:.5rem;background:var(--prompt-#{accent}-bg);color:var(--prompt-text-color);) +
      %(font-size:.9rem;line-height:1.4;">#{icon_link}#{text}</div>)
  end
end

Jekyll::Hooks.register :posts, :pre_render do |post|
  raw = post.data['ai']
  next if raw.nil? || raw == false

  type = AIDisclosure.normalize(raw)
  if type.nil?
    Jekyll.logger.warn 'AI-Disclosure:',
                       "Unbekannter Wert fuer 'ai' in #{post.relative_path}: " \
                       "#{raw.inspect} (erlaubt: full, partial)"
    next
  end

  cfg = post.site.data['ai_disclosure']
  if cfg.nil?
    Jekyll.logger.warn 'AI-Disclosure:',
                       '_data/ai_disclosure.yml fehlt – Kennzeichnung wird uebersprungen.'
    next
  end

  baseurl = post.site.config['baseurl'].to_s
  post.content = "#{AIDisclosure.box_html(type, cfg, baseurl)}\n\n#{post.content}"
end
