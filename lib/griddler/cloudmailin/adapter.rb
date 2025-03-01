module Griddler
  module Cloudmailin
    class Adapter
      def self.normalize_params(params)
        adapter = new(params)
        adapter.normalize_params
      end

      def normalize_params
        normalized_params = base_params
        normalized_params[:bcc] = bcc unless bcc.empty?
        normalized_params
      end

      def legacy?
        @legacy ||= headers.key? :From
      end

      private

      attr_reader :params

      def initialize(params)
        @params = params
      end

      def recipients(field)
        headers[field].to_s.split(',').map(&:strip)
      end

      def ccs
        @ccs ||= recipients(header_keys[:cc])
      end

      def tos
        @tos ||= recipients(header_keys[:to])
      end

      def envelope_to
        @envelope_to ||= params[:envelope][:to]
      end

      def header_emails
        @header_emails ||= (tos | ccs).map { |addressee| Griddler::EmailParser.parse_address(addressee)[:email] }
      end

      def bcc
        @bcc ||= header_emails.include?(envelope_to) ? [] : [envelope_to]
      end

      def headers
        @headers ||= params[:headers]
      end

      def base_params # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        puts "*********xxx*********"
        puts "*********xxx*********"
        puts "*********xxx*********"
        puts "Cloudmail Adapter Params"
        puts "From: #{headers[header_keys[:from]].inspect.to_s}"
        puts "date: #{headers[header_keys[:date]].try(:to_datetime)}"
        puts "to: #{tos.inspect.to_s}"
        puts "cc: #{ccs.inspect.to_s}"
        puts "subject: #{headers[header_keys[:subject]].inspect.to_s}"
        puts "text: #{params[:plain]}"
        puts "html:"
        puts params[:html].inspect.to_s
        puts "attachments:"
        puts params.fetch(:attachments).inspect.to_s
        puts "headers"
        puts headers.inspect.to_s
        puts "params"
        puts params.inspect.to_s
        puts "*********xxx*********"
        puts "*********xxx*********"
        puts "*********xxx*********"
        @base_params ||= {
          to: tos,
          cc: ccs,
          from: headers[header_keys[:from]],
          date: headers[header_keys[:date]].try(:to_datetime),
          subject: headers[header_keys[:subject]],
          text: params[:plain],
          html: params[:html],
          attachments: params.fetch(:attachments),
          headers: headers
        }
      end

      def header_keys
        @header_keys ||= Hash[legacy? ? KEY_LIST.map { |s| [s, s.capitalize] } : KEY_LIST.map { |s| [s, s] }]
      end

      KEY_LIST = [:from, :to, :cc, :date, :subject].freeze
    end
  end
end
