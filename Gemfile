source 'https://rubygems.org'
gemspec

group :test do
  gem "minitest-reporters"
  gem "minitest-profile"
  gem "shoulda"
  gem "rspec"
  gem "rspec-mocks"
  gem "test-theme", path: File.expand_path("test/fixtures/test-theme", File.dirname(__FILE__))
  gem "test-plugin", path: File.expand_path("test/fixtures/test-plugin", File.dirname(__FILE__))
  gem "another-test-plugin", path: File.expand_path("test/fixtures/another-test-plugin", File.dirname(__FILE__))
  gem "activesupport", "~> 4.2" if RUBY_VERSION < '2.2.2'
end
