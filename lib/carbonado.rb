require "carbonado/version"

module Carbonado
  class Error < StandardError; end
  
  # Activate the named gem. Specify a version requirement as a string or a Gem::Requirement
  # object. This will also recursively activate the dependencies of the gem. It can fail if a gem
  # has a dependency that is already activated which doesn't satisfy the requirements of the given
  # gem or one of its dependencies. Otherwise it can fail if the given gem or one of its 
  # dependencies is not installed
  def activate_gem(gem_name, version = nil, requirer = nil)
    version_requirement = version.is_a?(Gem::Requirement) ? version : Gem::Requirement.default
    loaded_gem = Gem::Specification.stubs.select{ |s| s.name == gem_name }.first
    if !loaded_gem.nil?
      return true if Gem::Requirement.new(version_requirement).satisfied_by?(loaded_gem.version)      

      error_msg = "There is alread an activated version of #{gem_name}"
      error_msg += ", required by #{requirer}" if requirer
      error_msg += ", that does not meet the version requirement #{version_requirement}"
      raise Error, error_msg
    end
    installed_versions = installed_stubs.select{ |s| s.name == gem_name }.sort_by(&:version)
    raise Error, "Could not find #{gem_name} in list of installed gems" if installed_versions.empty?
    allowed_versions = installed_versions.select do |s|
      Gem::Requirement.new(version_requirement).satisfied_by?(s.version)
    end

    selected_spec = allowed_versions.last.to_spec
    selected_spec.dependencies.select(&:runtime?).each{ |dep| activate_gem(dep.name) }    
    selected_spec.activate
  end

  # This method stubs the Kernel#gem method to make it a noop for the code executed in the yielded 
  # block. This method is useful if there is a gem that uses the Kernel#gem method to activate a
  # gem from the bundle that you have already activated using the activate_gem method above. One
  # example is the ActiveRecord::Base.establish_connection method. Depending on the adapter, this
  # will try to activate the appropriate gem using the 'gem' method, which will fail because our
  # approach doesn't alter the bundle. I guess this is a TODO, since it may be possible to update
  # the bundle so that the gem method will succeed which would be a better solution.
  def stub_gem_method
    Kernel.define_method :fake_gem do |*args|
    end

    Kernel.alias_method :real_gem, :gem
    Kernel.alias_method :gem, :fake_gem

    yield

    Kernel.alias_method :gem, :real_gem
  end

  private

  # This is a copy of the implementation of Gem::Specification.installed_stubs, however that
  # method is private, so it may change in subsequent versions of rubygems. Therefore we'll
  # implement it here just in case.
  def installed_stubs
    map_stubs(Gem::Specification.dirs, "*.gemspec") do |path, base_dir, gems_dir|
      Gem::StubSpecification.gemspec_stub(path, base_dir, gems_dir)
    end
  end

  def gemspec_stubs_in(dir, pattern)
    Gem::Util.glob_files_in_dir(pattern, dir).map { |path| yield path }.select(&:valid?)
  end

  def map_stubs(dirs, pattern) # :nodoc:
    dirs.flat_map do |dir|
      base_dir = File.dirname dir
      gems_dir = File.join base_dir, "gems"
      gemspec_stubs_in(dir, pattern) { |path| yield path, base_dir, gems_dir }
    end
  end

  # Also add these as class methods
  extend self
end
