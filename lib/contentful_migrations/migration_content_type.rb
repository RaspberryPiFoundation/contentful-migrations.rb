# frozen_string_literal: true

require 'contentful/management'

module ContentfulMigrations
  class MigrationContentType
    attr_reader :environment, :content_type_name

    def initialize(environment:, content_type_name:)
      @environment = environment
      @content_type_name = content_type_name
    end

    def content_type
      @content_type ||= find_or_create_content_type
    end

    private

    def content_types
      @content_types ||= environment.content_types
    end

    def find_or_create_content_type
      content_types.find(content_type_name)

      # This would be better if it were the proper
      # Contentful::Management::NotFound error, but they're difficult to
      # recreate in testing.
    rescue StandardError
      create_content_type
    end

    def create_content_type
      ct = content_types.create(
        name: content_type_name,
        id: content_type_name,
        description: 'Migration Table for interal use only, do not delete'
      )
      ct.fields.create(id: 'version', name: 'version', type: 'Integer')
      ct.save
      ct.publish

      ct
    end
  end
end
