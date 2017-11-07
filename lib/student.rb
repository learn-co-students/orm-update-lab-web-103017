require_relative "../config/environment.rb"
require 'pry'
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    DB[:conn].execute("create table students(id integer primary key, name text, grade text)")
  end

  def self.drop_table
    DB[:conn].execute("drop table students")
  end

  def update
      DB[:conn].execute("update students set name='#{self.name}', grade='#{self.grade}', id=#{self.id}")
  end

  def save
    #binding.pry
    if self.id != nil
      self.update
    else
      DB[:conn].execute("insert into students (name, grade) values ('#{self.name}', '#{self.grade}')")
      self.id = DB[:conn].execute("select id from students where name='#{self.name}'").flatten.join.to_i
    end
    #binding.pry
  end

  def self.create(name, grade)
    DB[:conn].execute("insert into students (name, grade) values ('#{name}', '#{grade}')")
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("select * from students where name='#{name}'")
    row.map do |x|
      new_student = Student.new(x[1], x[2], x[0])
      return new_student
    end
  end
end
