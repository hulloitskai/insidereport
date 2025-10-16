# typed: true
# frozen_string_literal: true

require "active_record"
require "open3"
require "uri"

class SchemaDumper
  extend T::Sig

  sig { params(database_url: String).void }
  def initialize(database_url)
    @database_url = database_url
  end

  sig { returns(String) }
  def dump
    uri = URI.parse(@database_url)

    case uri.scheme
    when "postgres", "postgresql", "postgis"
      dump_postgresql(uri)
    when "mysql", "mysql2"
      dump_mysql(uri)
    else
      raise ArgumentError, "Unsupported database type: #{uri.scheme}"
    end
  end

  private

  sig { params(uri: URI::Generic).returns(String) }
  def dump_postgresql(uri)
    cmd = [
      "pg_dump",
      "--schema-only",
      "--no-owner",
      "--no-acl",
      "--no-privileges",
      "-n",
      "public",
      @database_url,
    ]

    stdout, stderr, status = Open3.capture3(*cmd)
    raise "`pg_dump' failed: #{stderr}" unless status.success?

    stdout
  end

  sig { params(uri: URI::Generic).returns(String) }
  def dump_mysql(uri)
    database = scoped do
      path = uri.path || ""
      path[1..] || ""
    end

    cmd = [
      "mysqldump",
      "--no-data",
      "--skip-add-drop-table",
      "--compact",
      "--host=#{uri.host}",
      "--port=#{uri.port || 3306}",
      "--user=#{uri.user}",
      "--password=#{uri.password}",
      database,
    ]

    stdout, stderr, status = Open3.capture3(*cmd)
    raise "`mysqldump' failed: #{stderr}" unless status.success?

    stdout
  end
end
