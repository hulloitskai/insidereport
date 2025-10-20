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
      dump_postgres(uri)
    when "mysql", "mysql2"
      dump_mysql(uri)
    else
      raise ArgumentError, "Unsupported database type: #{uri.scheme}"
    end
  end

  private

  sig { params(uri: URI::Generic).returns(String) }
  def dump_postgres(uri)
    cmd = [
      "pg_dump",
      "--schema-only",
      "--no-owner",
      "--no-acl",
      "--no-privileges",
      "--no-security-labels",
      "--no-tablespaces",
      "--no-table-access-method",
      "--no-toast-compression",
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

    host = uri.host or raise "Missing host"
    user = uri.user or raise "Missing user"
    password = uri.password or raise "Missing password"

    cmd = [
      "mysqldump",
      "--no-data",
      "--skip-add-drop-table",
      "--compact",
      "--host",
      host,
      "--user",
      user,
      "--password",
      password,
    ]
    if (port = uri.port)
      cmd += ["--port", port.to_s]
    end
    cmd += ["--", database]

    stdout, stderr, status = Open3.capture3(*T.unsafe(cmd))
    raise "`mysqldump' failed: #{stderr}" unless status.success?

    stdout
  end
end
