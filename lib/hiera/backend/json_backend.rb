#
#   Copyright 2010, 2011 R.I.Pienaar
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
class Hiera
    module Backend
        class Json_backend
            def initialize
                require 'json'

                Hiera.debug("JSON Starting")
            end

            def lookup(key, scope, order_override=nil)
                answer = nil

                Hiera.debug("Looking up #{key} in JSON backup")

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
