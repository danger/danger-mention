require 'open-uri'

module Danger

  # Automatically mention potential reviewers on pull requests.
  # It downloads and parses the blame information of changed files
  # to figure out who may be a good reviewer.
  #
  # @example Specifying max reviewers.
  #
  #          # Find maximum two reviewers without specifying
  #          # ignored files and users
  #          mention.run(2, [], [])
  #
  class DangerMention < Plugin

    # Mention potential reviewers.
    #
    # @param   Integer max_reviewers
    #          Maximum number of people to ping in the PR message, default is 3.
    # @param   [String] file_blacklist
    #          Regexes of ignored files.
    # @param   [String] user_blacklist
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
      files = modified_files + deleted_files
      file_blacklist = file_blacklist.map { |f| /#{f}/ }
      re = Regexp.union(file_blacklist)

      files = files.select { |f| !f.match(re) }

      # select just 6 random files
      # gonna be changed in next version
      files[0...6]
    end


    def compose_urls(files)
      host = 'https://' + env.request_source.host
      repo_slug = env.ci_source.repo_slug
      path = host + '/' + repo_slug + '/' + 'blame' + '/' + branch_for_base

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
      user_blacklist << pr_author
      users = users.select { |k, _| !user_blacklist.include? k }

      max_values = users.values.sort.reverse[0..max_reviewers]
      users = users.select { |_, v| max_values.include? v }

      users.keys
    end

  end
end
