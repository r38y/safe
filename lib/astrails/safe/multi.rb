require 'tmpdir'

module Astrails
  module Safe
    class Multi < Sink

      protected

      def active?
        @backup.multi
      end

      def path
        @path ||= File.expand_path(expand(@config[:local, :path] || raise(RuntimeError, "missing :local/:path")))
      end
      
      def save
        v "=> Backup up multiple files..."
        v "  backup command: #{@backup.command}"

        @backup.path = full_path # need to do it outside DRY_RUN so that it will be avialable for S3 DRY_RUN
        # @backup.path << ".tgz"

        compression = "tar cf#{$_VERBOSE ? "v" : ""}z #{@backup.path} dump/"
        v "  compression command: #{compression}"

        
        unless $DRY_RUN
          Dir.tmpdir do
            v "  executing..."
            v "----"
            v ""

            out = ">> /dev/null" unless $_VERBOSE
            benchmark = Benchmark.realtime do
              system "#{@backup.command}#{out}"
              system "#{compression}#{out}"
            end
            
            v ""
            v "----"
            v "  command took " + sprintf("%.2f", benchmark) + " second(s)."
          end
        end
        
        @backup.processed = true
        @backup.compressed = true
        
        v "=> done!"
        v ""
      end

      def cleanup
        return unless keep = @config[:keep, :local]

        puts "listing files #{base}" if $_VERBOSE

        files = Dir["#{base}*"] .
          select{|f| File.file?(f) && File.size(f) > 0} .
          sort

        cleanup_with_limit(files, keep) do |f|
          puts "removing local file #{f}" if $DRY_RUN || $_VERBOSE
          File.unlink(f) unless $DRY_RUN
        end
      end
    end
  end
end

class Dir
   module Tmpdir
     require 'tmpdir'
     require 'socket'
     require 'fileutils'

     unless defined?(Super)
       Super = Dir.send(:method, :tmpdir)
       class << Dir
         remove_method :tmpdir
       end
     end

     class Error < ::StandardError; end

     Hostname = Socket.gethostname || 'localhost'
     Pid = Process.pid
     Ppid = Process.ppid

     def tmpdir *args, &block
       options = Hash === args.last ? args.pop : {}

       dirname = Super.call(*args)

       return dirname unless block

       turd = options['turd'] || options[:turd]

       basename = [
         Hostname,
         Ppid,
         Pid,
         Thread.current.object_id.abs,
         rand
       ].join('-')

       pathname = File.join dirname, basename

       made = false

       42.times do
         begin
           FileUtils.mkdir_p pathname
           break(made = true)
         rescue Object
           sleep rand
           :retry
         end
       end

       raise Error, "failed to make tmpdir in #{ dirname.inspect }" unless made

       begin
         return Dir.chdir(pathname, &block)
       ensure
         unless turd
           FileUtils.rm_rf(pathname) if made
         end
       end
     end
   end

   extend Tmpdir
end
