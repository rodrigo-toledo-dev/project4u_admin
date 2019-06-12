Device.destroy_all
User.destroy_all
Client.destroy_all
Client.create!(name: 'Project4U')
client = Client.first
client.users.build(first_name: 'Rodrigo', last_name: 'Toledo', password: 'asdasdasd', password_confirmation: 'asdasdasd', email: 'rodrigo@rtoledo.inf.br')
client.users.build(first_name: 'Denise', last_name: 'Almeida', password: 'asdasdasd', password_confirmation: 'asdasdasd', email: 'denise.almeida@agence.com.br')
client.save!