require File.expand_path('../spec_helper', __FILE__)

module Danger

  describe DangerMention do
    before do
      @mention = testing_dangerfile.mention
      DangerMention.send(:public, *DangerMention.private_instance_methods)
    end

    it 'is a plugin' do
      expect(Danger::DangerMention < Danger::Plugin).to be_truthy
    end

    describe :select_files do
      before do
        modified_files = (1..2).to_a.map { |i| format('M%d', i) }
        deleted_files = (1..2).to_a.map { |i| format('D%d', i) }
        allow(Finder).to receive(:parse).and_return(modified_files + deleted_files)
      end

      it 'takes first 3 modified files' do
        files = @mention.select_files([])
        expect(files).to eq %w(M1 M2 D1)
      end

      it 'does not return blacklisted files' do
        files = @mention.select_files(['M.*'])
        expect(files).to eq %w(D1 D2)
      end
    end

    describe :compose_urls do
      before do
        allow(@mention).to receive_message_chain('env.request_source.host').and_return('host')
        allow(@mention).to receive_message_chain('env.ci_source.repo_slug').and_return('slug')
        allow(@mention).to receive_message_chain('github.branch_for_base').and_return('branch')
      end

      it 'composes urls for files' do
        files = (1..4).to_a.map { |i| format('M%d', i) }
        expected = files.map { |f| format('https://host/slug/blame/branch/%s', f) }
        results = @mention.compose_urls(files)
        expect(results).to eq expected
      end

      describe :compose_urls do
        before do
          allow(@mention).to receive(:pr_author).and_return('author')
        end

        it 'finds potential reviewers' do
          users = Hash[(1..10).to_a.collect { |v| [format('user%s', v), v] }]
          expected = %w(user10 user9 user8)
          results = @mention.find_reviewers(users, [], 3)

          expect(results).to eq expected
        end

        it 'does not return pr author' do
          users = Hash['author' => 1]
          results = @mention.find_reviewers(users, [], 3)

          expect(results).to eq []
        end

        it 'does not return blacklisted users' do
          users = Hash['user10' => 1]
          results = @mention.find_reviewers(users, ['user10'], 1)

          expect(results).to eq []
        end
      end

      describe :run do
        before do
          allow(@mention).to receive(:select_files).and_return(%w(M1 M2))
          allow(@mention).to receive(:parse_blame).and_return({})
          allow(@mention).to receive(:find_reviewers).and_return(%w(user1 user2))
        end

        it 'mentions potential reviewers' do
          @mention.run
          output = @mention.status_report[:markdowns].first.message

          expect(output).to_not be_empty
          expect(output).to include('@user1')
          expect(output).to include('@user2')
        end
      end

    end
  end
end
