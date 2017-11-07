require_relative "../config/environment.rb"
require 'pry'
class Student

  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = "CREATE TABLE students(id INTEGER PRIMARY KEY, name TEXT, grade TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?,?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_stud = Student.new(name, grade)
    new_stud.save
  end

  def self.new_from_db(row)
    name = row[1]
    grade = row[2]
    id =row[0]
    new_stud = Student.new(name,grade,id)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id =?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = '#{name}'"
    row = DB[:conn].execute(sql).flatten
    Student.new_from_db(row)
  end
end
