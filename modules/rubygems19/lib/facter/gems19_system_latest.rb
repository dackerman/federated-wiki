if Object.const_defined?(:Facter)
  # this is a hack to install rubygems during collecting of facts
  lambda do # we wrap the code to a lambda so that we can use "return" to exit early
    begin
      # install the rubygems package
      catalog = Puppet::Resource::Catalog.new()
      catalog.add_resource(Puppet::Resource.new('Package', 'rubygems19'))
      return if catalog.to_ral.apply().any_failed?()
    rescue SystemExit, NoMemoryError
      raise
    rescue Exception => e
      Facter.debug("could not install rubygems: #{e}\n#{e.backtrace}")
      return
    end

    thisfile = File.expand_path(__FILE__)

    Facter.add('gems19_system_latest') do
      setcode do
        # run this file in a separate ruby interpreter
        system('ruby1.9', thisfile)
      end
    end

    Facter.add('rubysitedir19') do
      setcode do
        IO.popen('-') do |io|
          if io.nil?
            ENV.delete('RUBYLIB')
            exec('ruby1.9', '-e', 'print $:[0]')
          else
            io.read()
          end
        end
      end
    end
  end.call
else
  # this is executed if not run from facter
  require 'rubygems'

  name = 'rubygems-update'
  dependency = Gem::Dependency.new(name, "> #{Gem::VERSION}")
  candidates = Gem::SpecFetcher.fetcher.find_matching(dependency)

  latest = candidates.find() { |(candidate_name, _, candidate_platform),|
    candidate_name == name && Gem::Platform.match(candidate_platform)
  }.nil?

  exit latest ? 0 : 1
end
