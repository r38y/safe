module Astrails
  module Safe
    class Mongodbdump < Source
      def command
        command = ["mongodump"]
        command << @config[:options] if @config[:options]
        command << "--db #{@id}"
      
        %w[host port out collection].each do |opt|
          command << "--#{opt} #{@config[opt]}" if @config[opt]
        end

        command.join(" ")
      end
      
      def backup
        bkp = super
        bkp.multi = true
        bkp
      end

      def extension; '.mongodb.dump.tgz'; end
    end
  end
end