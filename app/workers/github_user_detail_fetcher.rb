require 'octokit'

class GitHubUserDetailsFetcher
  include Sidekiq::Worker
  def perform(user_id)
    user = User.find(user_id)
    puts "processing user '#{user.username}'"

    github_user = Octokit.user user.username
    puts "fetched user from GitHub API: #{github_user}"

    [:name, :location, :email].each do |attr|
      if user[attr].empty? && github_user[attr].present?
        user[attr] = github_user[attr]
      end
    end
    user.save!
    puts "updated user: #{user}"
  end
end
