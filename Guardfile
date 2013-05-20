# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html))).*}) { |m| "/assets/#{m[3]}" }
end

guard 'rspec', all_on_start: false, all_after_pass: false, zeus: true, bundler: false do
# guard 'rspec', all_on_start: false, all_after_pass: false, bundler: false, :spec_paths => "test"  do
  watch(%r|^spec\/(.*)\/?(.*)_spec\.rb|)
  watch(%r|^spec\/spec_helper\.rb|)      { "spec" }
  watch(%r|factories.rb|)                { "spec" }
  
  # Rails
  watch(%r|^app\/models\/(.*)\.rb|)      { |m| "spec/models/#{m[1]}_spec.rb"}
  watch(%r|^app\/workers\/(.*)\.rb|)      { |m| "spec/workers/#{m[1]}_spec.rb"}
  watch(%r|^app\/controllers\/(.*)\.rb|) { |m| "spec/functional/#{m[1]}_spec.rb" }
  watch(%r|^app\/helpers\/(.*)\.rb|)     { |m| "spec/helpers/#{m[1]}_spec.rb" }
  watch(%r|^lib\/(.*)\/(.*).rb|)         { |m| "spec/lib/#{m[1]}/#{m[2]}_spec.rb" }
end

guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end

guard 'annotate' do
  watch( 'db/schema.rb' )

  # Uncomment the following line if you also want to run annotate anytime
  # a model file changes
  #watch( 'app/models/**/*.rb' )

  # Uncomment the following line if you are running routes annotation
  # with the ":routes => true" option
  #watch( 'config/routes.rb' )
end
