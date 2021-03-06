function gui

    % Prepare for figure window to be created
    set(0,'units','pixels'); 
    screen_size = get(0,'screensize');
    width = screen_size(3);
    height = screen_size(4);
    
    % Initialise variables
    k = 0;
    max_iterations = 0;
    image_selected = 0;
    image = [];
    k_image = [];
    file = '';
    path = '';
    
    % Create figure window to add components
    fig = figure('Visible', 'off', 'Name', 'k-colour Image Creator', 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
        'Color', 'white', 'Position', [(width * 0.2), (height * 0.2), (width * 0.6), (height * 0.6)]);

    % Create panels for initial, options screen
    
    image_panel = uipanel('Title', "Image Preview", 'TitlePosition', 'centertop','FontSize', 12, 'BackgroundColor', 'white', ...
        'Position', [0.02, 0.05, 0.7, 0.9]);
    options_panel = uipanel('Title', "Options", 'TitlePosition', 'centertop','FontSize', 12, 'BackgroundColor', 'white', ...
        'Position', [0.73, 0.05, 0.25, 0.9]); 
    
    % Create axes for image_panel to plot graphics on
    image_panel_axes = axes('parent', image_panel, 'Visible', 'off');
    image_panel_axes.Visible = 'off';
   
    % Create components for initial, options screen
    
    no_image_txt = uicontrol('Parent', image_panel, 'Style', 'text', 'String', 'No image selected', 'BackgroundColor', 'white', ...
        'FontSize', 10);
    set(no_image_txt, 'units','normalized'); 
    no_image_txt.Position = [0.3, 0.4, 0.4, 0.2];
    
    image_txt = uicontrol('Parent', options_panel, 'Style', 'text', 'String', 'No image selected', 'FontSize', 10, ...
        'HorizontalAlignment', 'left');
    set(image_txt, 'units','normalized'); 
    image_txt.Position = [0.03, 0.82, 0.94, 0.06];
    
    select_photo_pb = uicontrol('Parent', options_panel, 'Style', 'pushbutton', 'String', 'Pick Image', 'FontSize', 10, ...
        'Callback', @selectPhotoCallback);
    set(select_photo_pb, 'units','normalized'); 
    select_photo_pb.Position = [0.03, 0.73, 0.5, 0.07];
    
    k_label = uicontrol('Parent', options_panel, 'Style', 'text', 'String', 'Number of colours (use a small number):', ...
        'FontSize', 10, 'BackgroundColor', 'white', 'HorizontalAlignment', 'left');
    set(k_label, 'units','normalized'); 
    k_label.Position = [0.03, 0.58, 0.94, 0.1];
    
    k_edit = uicontrol('Parent', options_panel, 'Style', 'edit', 'String', '0', 'FontSize', 10, 'BackgroundColor', 'white', ...
        'HorizontalAlignment', 'left', 'Callback', @kCallback, 'enable', 'inactive', 'ButtonDownFcn', @kEditFocus);
    set(k_edit, 'units','normalized'); 
    k_edit.Position = [0.03, 0.5 0.94, 0.07];
    
    max_iterations_label = uicontrol('Parent', options_panel, 'Style', 'Text', 'String', ...
        'Maximum number of iterations (e.g. 200):', 'FontSize', 10, 'BackgroundColor', 'white', 'HorizontalAlignment', 'left');
    set(max_iterations_label, 'units','normalized'); 
    max_iterations_label.Position = [0.03, 0.35, 0.94, 0.1];
    
    max_iterations_edit = uicontrol('Parent', options_panel, 'Style', 'edit', 'String', '0', 'FontSize', 10, ...
        'BackgroundColor', 'white', 'HorizontalAlignment', 'left', 'Callback', @maxIterationsCallback, 'enable', 'inactive', 'ButtonDownFcn', @maxIterationsEditFocus);
    set(max_iterations_edit, 'units','normalized'); 
    max_iterations_edit.Position = [0.03, 0.27, 0.94, 0.07];

    done_pb = uicontrol('Parent', options_panel, 'Style', 'pushbutton', 'String', 'Done', 'FontSize', 12, ...
        'Callback', @doneCallback);
    set(done_pb, 'units','normalized'); 
    done_pb.Position = [0.25, 0.1, 0.5, 0.1];

    % Create, but don't yet display, panels for second screen
    
    k_image_panel = uipanel('Title', "k-image Preview", 'TitlePosition', 'centertop','FontSize', 12, ...
        'BackgroundColor', 'white', 'Visible', 'off', 'Position', [0.02, 0.12, 0.5, 0.86]);
    plot_panel = uipanel('Title', ['Colour space data for ' file], 'TitlePosition', 'centertop','FontSize', 12, ...
        'BackgroundColor', 'white', 'Visible', 'off', 'Position', [0.53, 0.12, 0.45, 0.86]); 
    button_panel = uipanel('BorderType', 'none', 'BackgroundColor', 'white', 'Visible', 'off', 'Position', ...
        [0.02, 0.01, 0.98, 0.11]); 
    
    k_image_panel_axes = axes('parent', k_image_panel, 'Visible', 'off');
    plot_axes = axes('parent', plot_panel, 'Visible', 'off');
    
    % Create components for second screen
    
    save_pb = uicontrol('Parent', button_panel, 'Style', 'pushbutton', 'String', 'Restart', 'FontSize', 12, ...
        'Callback', @restartCallback);
    set(save_pb, 'units','normalized'); 
    save_pb.Position = [0.1, 0.05, 0.2, 0.85];
    
    restart_pb = uicontrol('Parent', button_panel, 'Style', 'pushbutton', 'String', 'Save Image', 'FontSize', 12, ...
        'Callback', @saveCallback);
    set(restart_pb, 'units','normalized'); 
    restart_pb.Position = [0.4, 0.05, 0.2, 0.85];
    
    exit_pb = uicontrol('Parent', button_panel, 'Style', 'pushbutton', 'String', 'Exit Program', 'FontSize', 12, ...
        'Callback', @exitCallback);
    set(exit_pb, 'units','normalized'); 
    exit_pb.Position = [0.7, 0.05, 0.2, 0.85];
    
    
    fig.Visible = 'on';

    % Pushbutton callback functions
    function selectPhotoCallback(~,~)     
        
        % Only allow file selection of image files
        [file,path] = uigetfile({'*.JPG;*.JPEG;*.PNG;*.BMP', 'Image Files'});

        % If an image file was successfully selected...
        if file ~= 0
            % Remove any existing images
            cla(image_panel_axes);
            
            % Display name of image selected in an edit box to enable scrolling
            image_txt = uicontrol('Parent', options_panel, 'Style', 'edit', 'String', file, 'FontSize', 10, ...
                'HorizontalAlignment', 'left', 'min', 0,'max', 3, 'enable','inactive');
            set(image_txt, 'units','normalized'); 
            image_txt.Position = [0.03, 0.82, 0.94, 0.07];
            no_image_txt.Visible = 'off';
            
            % Display image in figure
            image = imread(strcat(path,file));
            imshow(image, 'Parent', image_panel_axes);
            image_selected = 1;
        end
    end

    % Editable textbox callback functions
    
    function kCallback(source,~)
        % Make sure that a number of colours has been entered and is greater than 0, otherwise display a warning
        k_text = get(source, 'String');
        if isnan(str2double(k_text)) || str2double(k_text) == 0
            set(source, 'String',' 0');
            warndlg('Please enter a number of colours that is greater than 0.');
        else
            k = str2double(k_text);
        end
        
    end

    function maxIterationsCallback(source,~)
        % Make sure that a maximum number of iterations has been entered and is greater than 0, otherwise display a warning
        max_iterations_text = get(source, 'String');
        if isnan(str2double(max_iterations_text)) || str2double(max_iterations_text) == 0
            set(source, 'String',' 0');
            warndlg('Please enter a maximum number of iterations that is greater than 0.');
        else
            max_iterations = str2double(max_iterations_text);
        end
        
    end

    % Handle behaviour when number of colours is being entered
    function kEditFocus(~, ~)
        set(k_edit, 'String', '');
        k_edit.Enable = 'on';
        uicontrol(k_edit);
    end

    % Handle behaviour when max iterations is being entered
    function maxIterationsEditFocus(~, ~)
        set(max_iterations_edit, 'String', '');
        max_iterations_edit.Enable = 'on';
        uicontrol(max_iterations_edit);
    end

    function doneCallback(~, ~)
        
        % Only progress to generate k-image when user has entered all fields with valid values
        if image_selected == 1 && ~(k == 0 || max_iterations == 0)  
            image_panel.Visible = 'off';
            options_panel.Visible = 'off';
            k_image = ConvertImage(image, k, max_iterations);
            displayResultsScreen;
        else
            % Warnings to display if user has not entered valid values for options
            if image_selected == 0 
                warndlg('Please select an image');
            elseif k == 0
                warndlg('Please enter a number of colours greater than 0');
            elseif max_iterations == 0
                warndlg('Please enter a maximum number of iterations greater than 0'); 
            end
        end
    end

    % Display options screen as it appeared when application was first opened
    function displayOptionsScreen
        image_selected = 0;
        image = []; 
        
        set(k_edit, 'String', '');
        set(max_iterations_edit, 'String', '');
        
        cla(image_panel_axes);
        cla(k_image_panel_axes);
        cla(plot_axes);
        
        k_image_panel.Visible = 'off';
        plot_panel.Visible = 'off';
        button_panel.Visible = 'off';
        image_txt.Visible = 'off';
        
        image_panel.Visible = 'on';
        options_panel.Visible = 'on';
        no_image_txt.Visible = 'on';
        
        image_txt = uicontrol('Parent', options_panel, 'Style', 'text', 'String', 'No image selected', 'FontSize', 10, ...
            'HorizontalAlignment', 'left');
        set(image_txt, 'units','normalized'); 
        image_txt.Position = [0.03, 0.82, 0.94, 0.06];
    end

    function displayResultsScreen        
        k_image_panel.Visible = 'on';
        plot_panel.Visible = 'on';
        button_panel.Visible = 'on';

        cla(k_image_panel_axes);
        k_image_panel_axes.Visible = 'off';
        imshow(k_image, 'Parent', k_image_panel_axes);

        % Visualise colour data of image
        plot3(plot_axes, image(:,:,1),image(:,:,2),image(:,:,3),'+b')
        xlabel('red'); ylabel('green'); zlabel('blue');
        axis tight
        grid on
    end

    % Save image to directory of user's choice
    function saveCallback(~, ~) 
        dir = uigetdir('C:\');
        imwrite(k_image,[dir '\' num2str(k) 'colour' file]);
        
        image_saved_dialog = dialog('Name', 'Image Saved', 'Position', ...
            [(width * 0.35), (height * 0.4), (width * 0.3), (height * 0.2)]);
        image_saved_text = uicontrol('Parent', image_saved_dialog, 'Style', 'text', 'String', 'Image has been saved.', ...
            'FontSize', 12);
        image_saved_btn = uicontrol('Parent', image_saved_dialog, 'String','OK', 'FontSize', 12, 'Callback','delete(gcf)');
        
        set(image_saved_text, 'units','normalized');
        set(image_saved_btn, 'units','normalized');
        
        image_saved_text.Position = [0, 0.5, 1, 0.2]; 
        image_saved_btn.Position = [0.4, 0.1, 0.2, 0.2];
    end

    function restartCallback(~, ~) 
        displayOptionsScreen;
    end

    function exitCallback(~, ~)
        close all;
    end
end