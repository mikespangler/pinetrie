namespace :db do
  desc "Fill database"
  task :populate => :environment do
    260.times do
      person = Person.new
      person.name = Faker::Name.name
      person.url  = Faker::Internet.domain_name
      person.save
    end
  end
end