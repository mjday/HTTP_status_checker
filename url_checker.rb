require 'faraday'
require 'byebug'
require 'csv'
require 'openssl'

COURSES = Array.new

puts "Beginning to check the validity of each course url...."

class Status
    def get
        
        csv_options = { headers: :first_row, header_converters: :symbol, :row_sep => :auto, }
        filepath    = 'import.csv'
        
        CSV.foreach(filepath, csv_options).with_index do |row, line|
            url = row[:url]
            puts "_______"
            puts line
            puts url

            if url.nil? || !(url.start_with?('http://', 'https://'))
                row[:status] = "blank"
                COURSES << [row[:school], row[:qualification_earned], row[:course], row[:course_level], row[:url], row[:status]].flatten
            else
                check(url)
                row[:status] = @response.status if @response
                row[:errors] = @error if @error
                COURSES << [row[:school], row[:qualification_earned], row[:course], row[:course_level], row[:url], row[:status], row[:errors]].flatten
                
            end 
            puts row[:status]
            puts row[:errors]
            puts "........"
        end  

        csv_options_2 = { headers: :first_row, force_quotes: false }
        filepath_2    = 'export.csv'

        CSV.open(filepath_2, 'w', csv_options_2) do |csv|
            csv << ["School", "Qualification Earned", "Course", "Course Level", "URL", "HTTP_status", "Errors"]
            COURSES.each do |row|
                csv << row
            end
        end
    end


    def check(url)
        begin
            connection = Faraday::Connection.new(url, :ssl => {:ca_path => "/usr/lib/ssl/certs"})
            @response = connection.get(@url_prefix)
        rescue Faraday::ClientError => err
          @error = err.message
        end
    end
end


Status.new.get

puts "All URL's checked."


# PSEUDOCODE
# export all course data to csv
# open csv file and loop through the url field
# write the url status to a variable
# convert each url into a Faraday object if url is not equal to nil or begins with http (i.e. not a proper link)
# save the url status variable result back to the csv file in a new column
# analyse the status codes in a pivot table, to find the percentages of each
# use the pivot lists as a template for building a report into the db where we can filter and edit them directly


# TO ADD?
# how to check if there are more than 1 of the same url, i.e. duplicates
