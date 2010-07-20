require 'httpclient'
require 'uri'
require 'iconv'
require 'digest/md5'
require "base64"
require "rexml/document"
require "unicode_utils"

#
# Event Source for moneytrackin (http://moneytrackin.com) finance service
#
class MoneyTrackin < EventSourcePublic

  description "MoneyTrackin'"

  # Users credentials
  key :login, String
  key :password, String

  # This is 'known name', :password is stored into database only if it persistent
  key :is_persistent, Boolean

  # MoneyTrackin specific configuration:
  # Only transactions with these tags will be imported
  key :tags_to_import, String

  configuration << [:login, :password, :is_persistent]
  configuration << :tags_to_import

  def fetch(password)

    client = HTTPClient.new(ENV['http_proxy'])
    
    login, password = self.login, Digest::MD5.hexdigest(password)

    rest = "https://www.moneytrackin.com/api/rest/"

    header = { "Authorization" => "Basic "+ Base64.urlsafe_encode64(login + ":" + password) }

    args = {}
    args[:project] = '' unless args[:project]
    args[:sdate] = "1900-01-01" unless args[:sdate]
    args[:edate] = "2100-01-01" unless args[:edate]

    res = client.get(rest+"listTransactions?#{args[:project]}&startDate=#{args[:sdate]}&endDate=#{args[:edate]}",
                      nil, header
                     )
    content = res.content
    doc = REXML::Document.new(content)

    return if doc.root.attributes['code'] != 'done'

    tags = self.tags_to_import.split(/\s*[\,\;]\s*/) if self.tags_to_import

    tags = ['auto', 'fuel'] if tags.nil? or tags.empty?

    doc.root.elements.each {|el|
      item = {}
      item[:comment] = el.elements['description'].text
      item[:sum]     = el.elements['amount'].text.to_f.abs
      item[:date]    = Time.strptime(el.elements['date'].text, "%F")
      item[:tags]    = el.elements['tags'].elements.collect{|tag| tag.text }

      next unless item[:tags].detect{|t|  tags.detect{|tt| UnicodeUtils.downcase(tt) == UnicodeUtils.downcase(t) } }

      result = add_event(item)
    }
  end

end
