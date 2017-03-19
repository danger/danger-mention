require 'open-uri'
require_relative 'finder'

module Danger

  # Automatically mention potential reviewers on pull requests.
  # It downloads and parses the blame information of changed files
  # to figure out who may be a good reviewer.
  #
  # @example Running plugin with reviewers count specified
  #
  #          # Find maximum two reviewers
  #          mention.run(2, [], [])
  #
  # @example Running plugin with some files blacklisted
  #
  #          # Find reviewers without parsing blame information
  #          # from files matching to 'Pods/*'
  #          mention.run(2, ["Pods/*"], [])
  #
  # @example Running plugin with some users blacklisted
  #
  #          # Find reviewers ignoring users 'wojteklu' and 'danger'
  #          mention.run(2, [], ["wojteklu", "danger"])
  #
  # @tags github, review, mention, blame

  class DangerMention < Plugin

    # Mention potential reviewers.
    #
    # @param   [Integer] max_reviewers
    #          Maximum number of people to ping in the PR message, default is 3.
    # @param   [Array<String>] file_blacklist
    #          Regexes of ignored files.
    # @param   [Array<String>] user_blacklist
    #          List of users that will never be mentioned.
    # @return  [void]
    #
    def run(max_reviewers = 3, file_blacklist = [], user_blacklist = [])
      files = select_files(file_blacklist)
      return if files.empty?

      authors = {}
      compose_urls(files).each do |url|
        result = parse_blame(url)
        authors.merge!(result) { |_, m, n| m + n }
      end

      reviewers = find_reviewers(authors, user_blacklist, max_reviewers)

      if reviewers.count > 0
        reviewers = reviewers.map { |r| '@' + r }

        result = format('By analyzing the blame information on this pull '\
        'request, we identified %s to be potential reviewer%s.',
                        reviewers.join(', '), reviewers.count > 1 ? 's' : '')

        markdown result
      end
    end

    private

    def select_files(file_blacklist)
      files = Finder.parse(env.scm.diff)

      file_blacklist = file_blacklist.map { |f| /#{f}/ }
      re = Regexp.union(file_blacklist)
      files = files.select { |f| !f.match(re) }

      files[0...3]
    end

    def compose_urls(files)
      host = 'https://' + env.request_source.host
      repo_slug = env.ci_source.repo_slug

      path = ""
      if defined? @dangerfile.gitlab
        # https://gitlab.com/danger-systems/danger.systems/blame/danger_update/.gitlab-ci.yml
        path = host + '/' + repo_slug + '/' + 'blame' + '/' + gitlab.branch_for_base

      elsif defined? @dangerfile.github
        # https://github.com/artsy/emission/blame/master/dangerfile.js
        path = host + '/' + repo_slug + '/' + 'blame' + '/' + github.branch_for_base
      else
        raise "This plugin does not yet support bitbucket, would love PRs: https://github.com/danger/danger-mention/"
      end

      urls = []
      files.each do |file|
        urls << path + '/' + file
      end

      urls
    end

    def parse_blame(url)
      regex = %r{(?:rel="(?:author|contributor)">([^<]+)</a> authored|(?:<tr class="blame-line">))}
      source = open(url, &:read)
      matches = source.scan(regex).to_a.flatten

      current = nil
      lines = {}

      matches.each do |user|
        if user
          current = user
        else
          lines[current] = lines[current].to_i + 1
        end
      end

      lines
    end

    def find_reviewers(users, user_blacklist, max_reviewers)
      if defined? @dangerfile.gitlab
        user_blacklist << gitlab.mr_author
      elsif defined? @dangerfile.github
        user_blacklist << github.pr_author
      end

      users = users.select { |k, _| !user_blacklist.include? k }
      users = users.sort_by { |_, value| value }.reverse

      users[0...max_reviewers].map { |u| u[0] }.compact
    end

  end
end
