#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_helper'

class TestStatus < Test::Unit::TestCase
  def setup
    set_file_paths
    @git = Git.open(@wdir)
  end
  
  def add_ignore_files
    new_file('.gitignore', 'ignored_file')
    new_file('ignored_file', 'this file should be ignored')
  end

  def test_untracked
    in_temp_dir do |path|
      g = Git.clone(@wdir_dot, 'untracked_status_test')
      Dir.chdir('untracked_status_test') do
        assert(g.status.untracked.length == 0)
        new_file('one_new_file', 'this is the first new file')
        assert(g.status.untracked.length == 1)
        new_file('.second_new_file', 'this is a second new file, however it starts with a dot')
        assert(g.status.untracked.length == 2)
        add_ignore_files
        assert(g.status.untracked.length == 3)        
      end
    end
  end
  
  def test_added
    in_temp_dir do |path|
      g = Git.clone(@wdir_dot, 'added_status_test')
      Dir.chdir('added_status_test') do
        assert(g.status.added.length == 0)
        new_file('one_new_file', 'this is the first new file')
        assert(g.status.added.length == 0)
        g.add('one_new_file')
        assert(g.status.added.length == 1)
        new_file('.second_new_file', 'this is a second new file, however it starts with a dot')
        assert(g.status.added.length == 1)
        g.add('.second_new_file')
        assert(g.status.added.length == 2)
        add_ignore_files
        assert(g.status.added.length == 2)
        g.add('.gitignore')
        assert(g.status.added.length == 3)
      end
    end
  end
  
  def test_changed
    in_temp_dir do |path|
      g = Git.clone(@wdir_dot, 'changed_status_test')
      Dir.chdir('changed_status_test') do
        assert(g.status.changed.length == 0)
        append_file('example.txt', 'another line of text')
        add_ignore_files
        assert(g.status.changed.length == 1)
        g.add('.gitignore')
        g.commit('adding .gitignore')
        assert(g.status.changed.length == 1)
        append_file('.gitignore', '*~')
        assert(g.status.changed.length == 2)
        g.commit_all('commit all changes')
        assert(g.status.changed.length == 0)
      end
    end
  end
  
  def test_deleted
    in_temp_dir do |path|
      g = Git.clone(@wdir_dot, 'changed_status_test')
      Dir.chdir('changed_status_test') do
        assert(g.status.deleted.length == 0)
        rm_file('example.txt')
        assert(g.status.deleted.length == 1)
        g.commit_all('commit all changes')
        assert(g.status.deleted.length == 0)
      end
    end
  end

end