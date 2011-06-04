class Hiera
    module Backend
        class Json_backend
            def initialize
                require 'json'

                Hiera.warn("JSON Starting")
            end

            def lookup(key, scope, order_override=nil)
                answer = nil

                Hiera.warn("Looking up #{key} in JSON backup")

                datadir = Backend.datadir(:json, scope)

                raise "Cannot find data directory #{datadir}" unless File.directory?(datadir)

                Backend.datasources(scope, order_override) do |source|
                    unless answer
                        Hiera.warn("Looking for data source #{source}")

                        datafile = File.join([datadir, "#{source}.json"])

                        unless File.exist?(datafile)
                            Hiera.warn("Cannot find datafile #{datafile}, skipping")
                            next
                        end

                        data = JSON.parse(File.read(datafile))

                        next if data.empty?
                        next unless data.include?(key)

                        if data[key].is_a?(String)
                            answer = Backend.parse_string(data[key], scope)
                        else
                            answer = data[key]
                        end
                    else
                        break
                    end
                end

                answer
            end
        end
    end
end
