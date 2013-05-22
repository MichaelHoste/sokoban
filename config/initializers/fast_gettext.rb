FastGettext.add_text_domain 'sokoban', :path => 'config/gettext_locales', :type => :po
FastGettext.default_available_locales = ['fr', 'en'] # all you want to allow
FastGettext.default_text_domain = 'sokoban'
GettextI18nRails.translations_are_html_safe = true
