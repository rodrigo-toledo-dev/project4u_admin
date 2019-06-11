User.destroy_all
Client.destroy_all
Client.create!(name: 'Project4U')
client = Client.first
client.users.build(first_name: 'Rodrigo', last_name: 'Toledo', password: 'asdqwe123', password_confirmation: 'asdqwe123', email: 'rodrigo@rtoledo.inf.br')
client.users.build(first_name: 'Denise', last_name: 'Almeida', password: 'asdqwe123', password_confirmation: 'asdqwe123', email: 'denise.almeida@agence.com.br')
client.save!

puts User.count