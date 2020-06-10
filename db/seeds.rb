# coding: utf-8

User.create!(name: "管理者",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             affiliation: "管理",
             employee_number: "1",
             uid: "ID-01",
             search: "管理者",
             admin: true,
             superior: false)

User.create!(name: "上長A",
             email: "sampleA@email.com",
             password: "password",
             password_confirmation: "password",
             affiliation: "フリーランス",
             employee_number: "2",
             uid: "ID-02",
             search: "上長A",
             admin: false,
             superior: true)
 
User.create!(name: "上長B",
             email: "sampleB@email.com",
             password: "password",
             password_confirmation: "password",
             affiliation: "フリーランス",
             employee_number: "3",
             uid: "ID-03",
             search: "上長B",
             admin: false,
             superior: true)             
             
3.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  affiliation = "フリーランス"
  employee_number = n+1
  uid = "ID_#{n+1}"
  User.create!(name: name,
               email: email,
               password: password,
               affiliation: affiliation,
               employee_number: employee_number,
               uid: uid,
               password_confirmation: password)
end

puts "Users Created"

Base.create!(base_number: "1",
             base_name: "東京",
             base_type: "退勤")

Base.create!(base_number: "2",
             base_name: "横浜",
             base_type: "出勤")

Base.create!(base_number: "3",
             base_name: "大阪",
             base_type: "退勤")

puts "Base Created"