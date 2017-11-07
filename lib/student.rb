require_relative "../config/environment.rb"
require 'pry'
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id
  def initialize (id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
      SQL
      DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.grade)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
      self
  end

  def self.create (name, grade)
    student = self.new(name, grade)
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      data = DB[:conn].execute(sql, name, grade)
      student
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2])
    student.id = row[0]
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    id = row[0]
    name = row[1]
    grade = row[2]
    Student.new(id, name, grade)
  end

end
