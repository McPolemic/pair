require 'fileutils'
require 'rspec'

RSpec::Matchers.define :have_coauthor do |expected|
  match do |actual|
    Array(expected).each do |coauthor|
      last_block_index = actual.rindex("")
      actual[last_block_index..-1].include? "Co-authored-by: #{coauthor}"
    end
  end
end

RSpec.describe 'Running pair' do
  before do
    # Don't open an editor. Just give us some time to read what would have
    # been the commit message in `.git/COMMIT_EDITMSG`
    ENV['EDITOR'] = 'sleep'
  end

  # For each test, set up a new test directory, initialize a new repo with one
  # new file, added and ready to commit
  before(:each) do
    FileUtils.rm_rf("./test_repo")
    FileUtils.mkdir("./test_repo")
    FileUtils.cd("./test_repo")
    `git init .`
    File.write("a_file", "here are some contents")
    `git add .`
  end

  after(:each) do
    FileUtils.cd("..")
    FileUtils.remove_dir("./test_repo", force=true)
  end

  context 'when there is no set pair' do
    it 'prompts you to add a pair' do
      output = run("pair commit -m 'this is my commit'")
      expected = %q{Error: Set $PAIR before running. Example: $ PAIR="example name <example@example.com>"}

      expect(output.strip).to eq expected
    end
  end

  context 'when there are one or more pairs' do
    let(:coauthors) { ["name <name@example.com>", "other name <other_name@example.com>"] }

    before(:each) do
      ENV['PAIR'] = coauthors.join(",")
    end

    after(:each) do
      ENV.delete('PAIR')
    end

    context 'when specifying a commit message on the command line' do
      it 'makes a commit with the pair as coauthor' do
        run("pair commit -m 'this is my commit'")

        expect(commit_message_lines.first.strip).to eq 'this is my commit'
        expect(commit_message_lines).to have_coauthor coauthors
      end

      it 'allows multiple -m messages and includes the coauthor' do
        run("pair commit -m 'this is my commit' -m 'it took a lot of effort'")

        expect(commit_message_lines[0..2]).to eq ['this is my commit', '', 'it took a lot of effort']
        expect(commit_message_lines).to have_coauthor coauthors
      end
    end

    context 'when specifying a file for a commit on the command line' do
      it 'adds the coauthor to the commit' do
        pending

        File.write("commit_message_file", "This is my commit")

        run("pair commit -F commit_message_file")

        expect(commit_message_lines.first).to eq "This is my commit"

        coauthors.each do |coauthor|
          expect(commit_message_lines).to include "Co-authored-by: #{coauthor}"
        end
      end

      context 'when using --file=file' do
        it 'adds the coauthor to the commit' do
          pending

          File.write("commit_message_file", "This is my commit")

          run("pair commit -F commit_message_file")

          expect(commit_message_lines.first).to eq "This is my commit"

          coauthors.each do |coauthor|
            expect(commit_message_lines).to include "Co-authored-by: #{coauthor}"
          end
        end
      end
    end

    context 'when specifying a template for a commit on the command line' do
      it 'adds the coauthor to the template' do
        File.write("template_file", "This is my commit")

        run("pair commit -t template_file")

        expect(template_message_lines.first).to eq "This is my commit"

        coauthors.each do |coauthor|
          expect(template_message_lines).to include "Co-authored-by: #{coauthor}"
        end
      end

      context 'when using --template=template' do
        it 'adds the coauthor to the template with an equals sign' do
          pending
          File.write("template_file", "This is my commit")

          run("pair commit --template=template_file")

          expect(template_message_lines.first).to eq "This is my commit"

          coauthors.each do |coauthor|
            expect(template_message_lines).to include "Co-authored-by: #{coauthor}"
          end
        end
      end
    end

    context 'when committing without a message on the command line' do
      it 'makes a commit with the pair as coauthor' do
        run("pair commit")

        coauthors.each do |coauthor|
          expect(template_message_lines).to include "Co-authored-by: #{coauthor}"
        end
      end
    end
  end
end

# Grab the commit message's template (what would be presented to an editor when
# running `git commit`) as an array of lines
def template_message_lines
  lines = File.read("./.git/COMMIT_EDITMSG").lines.map(&:strip).compact
  comment_index = lines.find_index { |line| line.start_with? "# Please enter the commit message" }
  lines[0..comment_index-2]
end

# Grab the last commit message as an array of lines
def commit_message_lines
  `git log --format=%B -n 1`.strip.lines.map(&:strip)
end

# Run a given command (either a string or array) with stderr merged to stdout.
# Returns the output of the command
def run(command)
  path = ENV['PATH']
  pair_path = File.absolute_path(File.join(__dir__, ".."))
  env = { "PATH" => [pair_path, path].join(":") }

  IO.popen(env, command, :err=>[:child, :out]).read
end
