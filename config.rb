# frozen_string_literal: true

lib = File.expand_path('lib', __dir__).freeze
$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib

require 'middleman-blog/truncate_html'

module ::URI
  ##
  # Bug in Ruby 3.0.0
  #
  # undefined method `escape' for URI:Module
  # ~/.rvm/gems/ruby-3.0.0@crypto_libertarian-website/gems/middleman-core-4.3.11/lib/middleman-core/builder.rb:232:in `block in output_resource'
  #
  def self.escape(*args)
    DEFAULT_PARSER.escape(*args)
  end
end

module ::CryptoLibertarian
  module Website
    class Team
      attr_reader :members

      def initialize(members)
        self.members = members
        validate!
      end

    private

      def members=(array)
        @members = Array(array).map do |item|
          item = Hash(item).transform_keys { |key| String(key).to_sym }
          TeamMember.new(**item)
        end.freeze
      end

      def validate!
        ids = members.map(&:id)
        raise 'Non unique IDs' if ids != ids.uniq
      end
    end

    class TeamMember
      ID_RE = /\A[a-z][a-z0-9]*(_[a-z][a-z0-9]*)*\z/

      attr_reader :id, :first_name, :last_name, :description, :links

      def initialize(id:, first_name:, last_name:, description:, links:)
        self.id          = id
        self.first_name  = first_name
        self.last_name   = last_name
        self.description = description
        self.links       = links
      end

      def inspect
        "#<#{self.class}:#{id}>"
      end

      alias to_s inspect

      def to_h
        {
          id: id,
          first_name: first_name,
          last_name: last_name,
          description: description,
          links: links,
        }.freeze
      end

      def full_name
        @full_name ||= PropertyTranslation.new(
          **(first_name.locales + last_name.locales).uniq.map do |locale|
            [
              locale,
              "#{first_name.translate_to(locale)} #{last_name.translate_to(locale)}",
            ]
          end.to_h,
        )
      end

    private

      def id=(value)
        value = String(value).to_sym
        raise "Invalid ID: #{value}" unless ID_RE.match? value

        @id = value
      end

      def first_name=(hash)
        hash = Hash(hash).transform_keys { |key| String(key).to_sym }
        @first_name = PropertyTranslation.new(**hash)
      end

      def last_name=(hash)
        hash = Hash(hash).transform_keys { |key| String(key).to_sym }
        @last_name = PropertyTranslation.new(**hash)
      end

      def description=(hash)
        hash = Hash(hash).transform_keys { |key| String(key).to_sym }
        @description = PropertyTranslation.new(**hash)
      end

      def links=(array)
        @links = Array(array).map do |item|
          item = Hash(item).transform_keys { |key| String(key).to_sym }
          TeamMemberLink.new(**item)
        end.freeze
      end
    end

    class PropertyTranslation
      attr_reader :locale_to_translation

      def initialize(locale_to_translation)
        self.locale_to_translation = locale_to_translation
        validate!
      end

      def inspect
        "#<#{self.class}:#{locale_to_translation[:en]}>"
      end

      alias to_s inspect

      alias to_h locale_to_translation

      def locales
        locale_to_translation.keys
      end

      def translate_to(locale)
        locale_to_translation[locale] || locale_to_translation[:en]
      end

    private

      def locale_to_translation=(hash)
        @locale_to_translation = Hash(hash).map do |(locale, translation)|
          locale = String(locale).to_sym
          unless I18n.available_locales.include? locale
            raise "Invalid locale: #{locale.inspect}"
          end

          [locale, String(translation).freeze]
        end.to_h.freeze
      end

      def validate!
        return unless locale_to_translation[:en].strip.empty?

        raise 'Translation for locale "en" not found'
      end
    end

    class TeamMemberLink
      attr_reader :title, :url

      def initialize(title:, url:)
        self.title = title
        self.url   = url
      end

      def inspect
        "#<#{self.class}: title=#{title.inspect} url=#{url.inspect}>"
      end

      alias to_s inspect

      def to_h
        {
          title: title,
          url: url,
        }.freeze
      end

    private

      def title=(value)
        value = String(value).strip.freeze
        raise 'Blank title' if value.empty?

        @title = value
      end

      def url=(value)
        value = String(value).strip.freeze
        raise 'Blank URL' if value.empty?

        @url = value
      end
    end
  end
end

WEBPACK_SCRIPT =
  File.expand_path('node_modules/webpack/bin/webpack.js', __dir__).freeze

WEBPACK_BUILD = "#{WEBPACK_SCRIPT} --progress --color --bail"
WEBPACK_RUN   = "#{WEBPACK_SCRIPT} --progress --color --watch"

set(
  :external_links,
  telegram_channel: 'https://t.me/crypto_libertarian',
  telegram_chat: 'https://t.me/crypto_libertarian_chat',
  youtube_channel: 'https://www.youtube.com/channel/UCj9VPPL4riHinL3N9RbmLww',
  medium_blog: 'https://medium.com/crypto-libertarian',
)

set :css_dir,    'assets/stylesheets'
set :fonts_dir,  'assets/fonts'
set :images_dir, 'assets/images'
set :js_dir,     'assets/javascripts'

set :sass_assets_paths, %w[node_modules]

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true

page '/*.xml',  layout: false
page '/*.json', layout: false
page '/*.txt',  layout: false
page '/*.asc',  layout: false

activate :i18n, mount_at_root: :ru

activate :autoprefixer do |prefix|
  prefix.browsers = 'last 2 versions'
end

activate :blog do |blog|
  blog.layout = 'blog_article'
  blog.prefix = '/blog'
  blog.paginate = true
  blog.default_extension = '.md'

  blog.summary_generator = lambda do |blog_article, text, max_length, ellipsis|
    max_length = 250 if max_length.nil?
    ellipsis_length = ellipsis.length
    text = text.encode('UTF-8') if text.respond_to?(:encode)
    doc = Nokogiri::HTML::DocumentFragment.parse text
    actual_length = max_length - ellipsis_length
    doc.truncate(actual_length, ellipsis).inner_text
  end
end

configure :build do
  activate :relative_assets
end

configure :production do
  set :base_url, 'https://crypto-libertarian.com'
end

activate :external_pipeline,
         name: :webpack,
         command: build? ? WEBPACK_BUILD : WEBPACK_RUN,
         source: File.expand_path('tmp/webpack', __dir__),
         latency: 1

helpers do
  def translate(*args)
    I18n.translate(*args)
  end

  def base_url
    String(config[:base_url]).strip.tap do |base_url|
      raise 'Base URL is not configured' if base_url.empty?
    end
  end

  def absolute_urls?
    !String(config[:base_url]).strip.empty?
  end

  def absolute_url(relative_url)
    File.join base_url, relative_url
  end

  def absolute_canonical_url
    absolute_url current_page.url
  end

  def absolute_thumbnail_url
    absolute_url(
      if current_page.data.image.blank?
        image_path 'logo.jpg'
      else
        current_page.data.image
      end,
    )
  end

  def external_link(key)
    config[:external_links][key] or raise "Invalid key: #{key.inspect}"
  end

  def title
    if current_page.data.title.blank?
      translate :title
    else
      if current_page.data.title =~ /\A~(\w+)\z/
        "#{translate($1)} | #{translate(:title)}"
      else
        "#{current_page.data.title} | #{translate(:title)}"
      end
    end
  end

  def description
    if current_page.data.description.blank?
      if current_page.respond_to? :summary
        current_page.summary 250
      else
        translate :description
      end
    else
      if current_page.data.description =~ /\A~(\w+)\z/
        translate $1
      else
        current_page.data.description
      end
    end
  end

  def active_class(*urls)
    return ' active ' if urls.any? { |url| active_class? url }
  end

  def active_class?(url)
    case url
    when String
      current_page.url == url
    when Regexp
      current_page.url.match? url
    else
      raise TypeError
    end
  end

  def disabled_class_if(cond)
    ' disabled' if cond
  end

  def disabled_class_unless(cond)
    disabled_class_if !cond
  end

  def neg_tabindex_if(cond)
    '-1' if cond
  end

  def neg_tabindex_unless(cond)
    neg_tabindex_if !cond
  end

  def blog_feed_page_path(page_number)
    page_number = Integer page_number
    raise "Invalid page number: #{page_number}" unless page_number.positive?

    if page_number == 1
      '/blog/feed.html'
    else
      "/blog/feed/page/#{page_number}.html"
    end
  end

  def team_members
    CryptoLibertarian::Website::Team.new(data.team)
  end
end
