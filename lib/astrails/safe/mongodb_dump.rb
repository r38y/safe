module Astrails
  module Safe
    class MongodbDump < Source

      def command
        cmd = ["mongodump"]
        cmd << @config[:options] if @config[:options]
        
        %w[host port db out collection].each do |opt|
          cmd << "--#{opt} #{@config[opt]}" if @config[opt]
        end
        
        cmd.join " "
      end

      def extension; '.mongodb.dump'; end
    end
  end
end