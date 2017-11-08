require_relative "../config/environment.rb"
require "pry"
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_reader :id
  attr_accessor :name, :grade

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    if self.id #why self.id? becasue object id gets set once its been inserted to the databse.
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade) #putting (saving) values into students database
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0] #retrieving data id from database
      self #return the instance to be able to call the instance attributes
    end
    # binding.pry
    # self #return the instance to be able to call the instance attributes
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id) #putting(updating) the rows in the tables by referencing the id, for no duplicates
  end

  def self.create(name, grade) #creating an instance from student class
    self.new(name, grade).save #diff bw ::create and ::new_from_db. is that creates an obj/instance and saves it to the database (can edit before saving)
                              # while new_from_db retrieves the row from the database and creates an instance/object
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    self.new_from_db(found = DB[:conn].execute(sql, name)[0])
  end

  def self.new_from_db(row)
    self.new(row[1],row[2],row[0])
  end
end
