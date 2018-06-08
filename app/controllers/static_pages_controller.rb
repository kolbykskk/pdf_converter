require 'open-uri'

class StaticPagesController < ApplicationController

  def set_google_drive_token
    if request['code'] == nil
      redirect_to($drive.authorization_url)
    else
      $drive.save_credentials(request['code'])
      redirect_to('/')
    end
  end

  def home
    if params[:upload]
      all_names = []
      params[:upload].each_with_index do |file, index|
        read_file = File.read(file.tempfile)
        uploaded_file = File.open("uploaded_file_#{index}.pdf", "wb") { |file|
          file.write(read_file)
        }
        final_file = File.basename("uploaded_file_#{index}.pdf")
        PDF::Burst.new(final_file).run!
        4.downto(2).each do |i|
          File.delete("page_#{i}.pdf")
        end
        File.rename("page_1.pdf", "final_#{index+1}.pdf")
        all_names.push(Array(file.original_filename))
    end


      # convert each .pdf file to a .csv

      params[:upload].each_with_index do |file, index|
        read_file = File.read("final_#{index+1}.pdf")
        uploaded_file = File.open("uploaded_file_#{index}.pdf", 'w') { |file|
          file.write(read_file)
        }
        final_file = File.basename("uploaded_file_#{index}.pdf")

        response = PageTextReceiver.new(params)
        params[:index] = "#{index}"
        response.run(final_file)
      end

      params[:upload].each_with_index do |file, index|
        file_append = File.read("response_#{index}.csv")
        File.open("finalized.csv", "a") do |file|
          file << file_append
        end
      end

      temp_sheet = $drive.create("finalized")

      #check to make sure only .pdf files were uploaded
      params[:upload].each do |file|
        if File.extname(file.path) != ".pdf"
          flash[:alert] = "You can only upload .PDF files"
          return redirect_to root_path
        end
      end

      all_pulled_values = []

      cell = true;
      first_val = 5
      second_val = 35

      while cell == true
        begin
          response = $drive.sheet_get_values("#{temp_sheet.id}", "B#{second_val}")
        rescue Google::Apis::ClientError => error
          cell = false;
          break
        end
        if response.values
          response = $drive.sheet_get_values("#{temp_sheet.id}", "B#{first_val}:B#{second_val}")
          all_pulled_values.push response.values
          first_val = second_val + 9
          second_val = first_val + 30
        else
          cell = false;
        end
      end

      (all_pulled_values.count).times do |index|
        all_pulled_values[index].map! { |i| i.join() }
      end

      # Checks to see where the next empty row is to place new content

      cell = true
      index_for_append = 2

      while cell == true
        begin
          first_empty_row = $drive.sheet_get_values("#{params[:google_sheet_id]}", "A#{index_for_append}")
        rescue Google::Apis::ClientError => error
          cell = false;
          break
        end
        if first_empty_row.values
          index_for_append += 1
        else
          cell = false;
        end
      end

      puts "$$$$$$$$$$$$$$$$$$$$$#{index_for_append}"

      #######

      body = {"values": all_names}
      $drive.sheet_append_values("#{params[:google_sheet_id]}", "A2", body)

      all_pulled_values.each_with_index do |array, i|
        body = {"values": [array]}
        $drive.sheet_append_values("#{params[:google_sheet_id]}", "B#{index_for_append}:AF#{index_for_append}", body)
        index_for_append += 1
      end

      #Delete the file so it's fresh for next run
      File.delete("finalized.csv")

      $drive.delete("#{temp_sheet.id}")


      flash[:success] = "Success!"
      redirect_to root_path
    end
  end

  def generator
    result = $drive.create("generator_base")
    result = $drive.get("#{result.id}")
    flash[:info] = "#{result.alternate_link}<br>#{result.id}"

    redirect_to root_path

  end
end
