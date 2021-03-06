# frozen_string_literal: true

require "gems_bond/fetcher/ruby_gems"
require "gems_bond/fetcher/github"

module GemsBond
  # Handles gem data
  module FetchHelper
    RUBY_GEM_KEYS = %i[
      last_version_date
      downloads_count
      source_code_uri
      versions
      last_version
      last_version_date
      days_since_last_version
    ].freeze

    GITHUB_KEYS = %i[
      contributors_count
      stars_count
      forks_count
      last_commit_date
      open_issues_count
      days_since_last_commit
    ].freeze

    KEYS = RUBY_GEM_KEYS + GITHUB_KEYS

    RUBY_GEM_KEYS.each do |key|
      define_method(key) do
        memoize(key) do
          fetch(ruby_gems_fetcher, key)
        end
      end
    end

    GITHUB_KEYS.each do |key|
      define_method(key) do
        memoize(key) do
          fetch(github_fetcher, key)
        end
      end
    end

    def fetch_all(verbose: false)
      KEYS.each do |key|
        __send__(key)
      end
      verbose && puts(name)
    end

    private

    def fetch(fetcher, key)
      fetcher&.public_send(key)
    end

    def ruby_gems_fetcher
      return @ruby_gems_fetcher if defined?(@ruby_gems_fetcher)

      @ruby_gems_fetcher = GemsBond::Fetcher::RubyGems.new(name).start
    end

    def github_fetcher
      return @github_fetcher if defined?(@github_fetcher)

      @github_fetcher = github_url && GemsBond::Fetcher::Github.new(github_url).start
    end
  end
end
