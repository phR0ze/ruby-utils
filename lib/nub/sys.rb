#MIT License
#Copyright (c) 2018 phR0ze
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

require 'io/console'
require 'ostruct'
require 'stringio'
require_relative 'log'

module Sys
  extend self

  # Wait for any key to be pressed  
  def any_key?
    begin
      state = `stty -g`
      `stty raw -echo -icanon isig`
      STDIN.getc.chr
    ensure
      `stty #{state}`
    end
  end

  # Get the caller's filename for the caller of the function this call is nested in
  # not the function this call is called in
  # @returns [String] the caller's filename
  def caller_filename
    path = caller_locations(2, 1).first.path
    return File.basename(path)
  end

  # Capture STDOUT to a string
  # @returns [String] the redirected output
  def capture
    stdout, stderr = StringIO.new, StringIO.new
    $stdout, $stderr = stdout, stderr

    result = Proc.new.call

    $stdout, $stderr = STDOUT, STDERR
    $stdout.flush
    $stderr.flush

    return OpenStruct.new(result: result, stdout: stdout.string, stderr: stderr.string)
  end

  # Get the given environment variable by nam
  # @param var [String] name of the environment var
  # @param required [Bool] require that the variable exists by default
  def env(var, required:true)
    value = ENV[var]
    Log.die("#{var} env variable is required!") if required && !value
    return value
  end

  # Run the system command in an exception wrapper
  # @param cmd [String/Array] cmd to execute
  # @param env [Hash] optional environment variables to set
  # @param die [Bool] fail on errors if true
  # @returns boolean status, string message
  def exec(cmd, env:{}, die:true)
    result = false
    puts("exec: #{cmd.is_a?(String) ? cmd : cmd * ' '}")

    begin
      if cmd.is_a?(String)
        result = system(env, cmd, out: $stdout, err: :out)
      else
        result = system(env, *cmd, out: $stdout, err: :out)
      end
    rescue Exception => e
      result = false
      puts(e.message.colorize(:red))
      puts(e.backtrace.inspect.colorize(:red))
      exit if die
    end

    !puts("Error: failed to execute command properly".colorize(:red)) and
      exit unless !die or result

    return result
  end

  # Execute the shell command and print status
  # @param cmd [String] command to execute
  # @param die [bool] exit on true
  # @result status [bool] true on success else false
  def exec_status(cmd, die:true, check:nil)
    out = `#{cmd}`
    status = true
    status = check == out if !check.nil?
    status = $?.exitstatus == 0 if check.nil?

    #if status
    if status
      Log.puts("...success!".colorize(:green), stamp:false)
    else
      Log.puts("...failed!".colorize(:red), stamp:false)
      Log.puts(out.colorize(:red)) and exit if die
    end

    return status
  end

  # Read a password from stdin without echoing
  # @returns pass [String] the password read in
  def getpass
    print("Enter Password: ")
    pass = STDIN.noecho(&:gets).strip
    puts
    return pass
  end

  # Remove given dir or file
  # Params:
  # +path+:: path to delete
  # +returns+:: path that was deleted
  def rm_rf(path)
    Sys.exec("rm -rf #{path}")
    return path
  end

  # Unmount the given mount point
  # Params:
  # +mount+:: mount point to unmount
  # +retries+:: number of times to retry
  def umount(mount, retries:1)
    check = ->(mnt){
      match = `mount`.split("\n").find{|x| x.include?(mnt)}
      match = match.split('overlay').first if match
      return (match and match.include?(mnt))
    }

    success = false
    while not success and retries > 0
      if check[mount]
        success = system('umount', '-fv', mount)
      else
        success = true
      end

      # Sleep for a second if failed
      sleep(1) and retries -= 1 unless success
    end

    # Die if still mounted
    !puts("Error: Failed to umount #{mount}".colorize(:red)) and
      exit if check[mount]
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
