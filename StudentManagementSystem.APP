package studentmanagement;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.*;
import javafx.stage.Stage;
import javafx.stage.WindowEvent;

import java.io.*;
import java.util.*;

public class StudentManagementApp extends Application {
    private Stage primaryStage;
    private Student currentStudent;
    private List<Course> availableCourses;
    private List<Course> registeredCourses;

    // File paths for data storage
    private static final String STUDENT_DATA_FILE = "student_data.ser";
    private static final String COURSES_DATA_FILE = "registered_courses.ser";

    @Override
    public void start(Stage primaryStage) {
        this.primaryStage = primaryStage;
        primaryStage.setTitle("Student Management System");

        // Initialize data
        initializeData();

        // Load existing data
        loadStudentData();
        loadRegisteredCourses();

        // Set up close confirmation
        primaryStage.setOnCloseRequest(this::handleCloseRequest);

        // Show login page
        showLoginPage();

        primaryStage.show();
    }

    private void initializeData() {
        // Initialize available courses
        availableCourses = Arrays.asList(
                new Course("CS101", "Introduction to Java", 3),
                new Course("CS102", "Python Programming", 3),
                new Course("CS201", "Data Structures", 4),
                new Course("CS202", "Web Development", 3),
                new Course("CS301", "Database Systems", 4),
                new Course("CS302", "Software Engineering", 3),
                new Course("MATH201", "Discrete Mathematics", 3),
                new Course("MATH301", "Statistics", 3)
        );

        registeredCourses = new ArrayList<>();

        // Initialize default student if none exists
        if (currentStudent == null) {
            currentStudent = new Student("John Doe", "john.doe@email.com", "Computer Science", "Fall 2024");
        }
    }

    private void showLoginPage() {
        VBox loginBox = new VBox(15);
        loginBox.setAlignment(Pos.CENTER);
        loginBox.setPadding(new Insets(50));
        loginBox.setStyle("-fx-background-color: #f0f0f0;");

        Label titleLabel = new Label("Student Management System");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        Label subtitleLabel = new Label("Please login to continue");
        subtitleLabel.setStyle("-fx-font-size: 14px; -fx-text-fill: #7f8c8d;");

        GridPane loginForm = new GridPane();
        loginForm.setAlignment(Pos.CENTER);
        loginForm.setHgap(10);
        loginForm.setVgap(10);
        loginForm.setPadding(new Insets(20));
        loginForm.setStyle("-fx-background-color: white; -fx-background-radius: 10; -fx-effect: dropshadow(gaussian, rgba(0,0,0,0.1), 10, 0, 0, 2);");

        Label usernameLabel = new Label("Username:");
        TextField usernameField = new TextField();
        usernameField.setPromptText("Enter username");
        usernameField.setPrefWidth(200);

        Label passwordLabel = new Label("Password:");
        PasswordField passwordField = new PasswordField();
        passwordField.setPromptText("Enter password");
        passwordField.setPrefWidth(200);

        Button loginButton = new Button("Login");
        loginButton.setStyle("-fx-background-color: #3498db; -fx-text-fill: white; -fx-font-weight: bold; -fx-pref-width: 100;");
        loginButton.setOnAction(e -> {
            String username = usernameField.getText();
            String password = passwordField.getText();

            // Hardcoded credentials (you can modify this or load from file)
            if (("admin".equals(username) && "password".equals(password)) ||
                    ("student".equals(username) && "123".equals(password))) {
                showDashboard();
            } else {
                showAlert("Login Failed", "Invalid username or password!", Alert.AlertType.ERROR);
            }
        });

        // Add enter key support
        passwordField.setOnAction(e -> loginButton.fire());

        loginForm.add(usernameLabel, 0, 0);
        loginForm.add(usernameField, 1, 0);
        loginForm.add(passwordLabel, 0, 1);
        loginForm.add(passwordField, 1, 1);
        loginForm.add(loginButton, 1, 2);

        Label hintLabel = new Label("Hint: admin/password or student/123");
        hintLabel.setStyle("-fx-font-size: 12px; -fx-text-fill: #95a5a6;");

        loginBox.getChildren().addAll(titleLabel, subtitleLabel, loginForm, hintLabel);

        Scene scene = new Scene(loginBox, 600, 500);
        primaryStage.setScene(scene);
    }

    private void showDashboard() {
        VBox dashboardBox = new VBox(20);
        dashboardBox.setAlignment(Pos.CENTER);
        dashboardBox.setPadding(new Insets(30));
        dashboardBox.setStyle("-fx-background-color: #ecf0f1;");

        Label welcomeLabel = new Label("Welcome to Student Dashboard!");
        welcomeLabel.setStyle("-fx-font-size: 28px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        Label studentLabel = new Label("Student: " + currentStudent.getName());
        studentLabel.setStyle("-fx-font-size: 16px; -fx-text-fill: #34495e;");

        // Navigation buttons
        GridPane buttonGrid = new GridPane();
        buttonGrid.setAlignment(Pos.CENTER);
        buttonGrid.setHgap(15);
        buttonGrid.setVgap(15);

        Button profileButton = createDashboardButton("👤 Profile", "#e74c3c");
        profileButton.setOnAction(e -> showProfilePage());

        Button registerButton = createDashboardButton("📝 Register Course", "#27ae60");
        registerButton.setOnAction(e -> showRegisterCoursePage());

        Button viewCoursesButton = createDashboardButton("📚 View Courses", "#3498db");
        viewCoursesButton.setOnAction(e -> showViewCoursesPage());

        Button logoutButton = createDashboardButton("🚪 Logout", "#95a5a6");
        logoutButton.setOnAction(e -> showLoginPage());

        buttonGrid.add(profileButton, 0, 0);
        buttonGrid.add(registerButton, 1, 0);
        buttonGrid.add(viewCoursesButton, 0, 1);
        buttonGrid.add(logoutButton, 1, 1);

        dashboardBox.getChildren().addAll(welcomeLabel, studentLabel, buttonGrid);

        Scene scene = new Scene(dashboardBox, 700, 500);
        primaryStage.setScene(scene);
    }

    private Button createDashboardButton(String text, String color) {
        Button button = new Button(text);
        button.setPrefSize(200, 80);
        button.setStyle(String.format("-fx-background-color: %s; -fx-text-fill: white; -fx-font-size: 16px; -fx-font-weight: bold; -fx-background-radius: 10;", color));
        button.setOnMouseEntered(e -> button.setStyle(button.getStyle() + "-fx-effect: dropshadow(gaussian, rgba(0,0,0,0.3), 10, 0, 0, 2);"));
        button.setOnMouseExited(e -> button.setStyle(button.getStyle().replace("-fx-effect: dropshadow(gaussian, rgba(0,0,0,0.3), 10, 0, 0, 2);", "")));
        return button;
    }

    private void showProfilePage() {
        VBox profileBox = new VBox(20);
        profileBox.setPadding(new Insets(30));
        profileBox.setStyle("-fx-background-color: #ecf0f1;");

        Label titleLabel = new Label("Student Profile");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        GridPane profileForm = new GridPane();
        profileForm.setHgap(15);
        profileForm.setVgap(15);
        profileForm.setPadding(new Insets(20));
        profileForm.setStyle("-fx-background-color: white; -fx-background-radius: 10;");

        TextField nameField = new TextField(currentStudent.getName());
        TextField emailField = new TextField(currentStudent.getEmail());
        TextField programField = new TextField(currentStudent.getProgram());
        TextField semesterField = new TextField(currentStudent.getSemester());

        profileForm.add(new Label("Name:"), 0, 0);
        profileForm.add(nameField, 1, 0);
        profileForm.add(new Label("Email:"), 0, 1);
        profileForm.add(emailField, 1, 1);
        profileForm.add(new Label("Program:"), 0, 2);
        profileForm.add(programField, 1, 2);
        profileForm.add(new Label("Semester:"), 0, 3);
        profileForm.add(semesterField, 1, 3);

        HBox buttonBox = new HBox(10);
        buttonBox.setAlignment(Pos.CENTER);

        Button saveButton = new Button("Save Changes");
        saveButton.setStyle("-fx-background-color: #27ae60; -fx-text-fill: white; -fx-font-weight: bold;");
        saveButton.setOnAction(e -> {
            currentStudent.setName(nameField.getText());
            currentStudent.setEmail(emailField.getText());
            currentStudent.setProgram(programField.getText());
            currentStudent.setSemester(semesterField.getText());
            saveStudentData();
            showAlert("Success", "Profile updated successfully!", Alert.AlertType.INFORMATION);
        });

        Button backButton = new Button("Back to Dashboard");
        backButton.setStyle("-fx-background-color: #95a5a6; -fx-text-fill: white; -fx-font-weight: bold;");
        backButton.setOnAction(e -> showDashboard());

        buttonBox.getChildren().addAll(saveButton, backButton);

        profileBox.getChildren().addAll(titleLabel, profileForm, buttonBox);

        Scene scene = new Scene(profileBox, 600, 500);
        primaryStage.setScene(scene);
    }

    private void showRegisterCoursePage() {
        VBox registerBox = new VBox(20);
        registerBox.setPadding(new Insets(30));
        registerBox.setStyle("-fx-background-color: #ecf0f1;");

        Label titleLabel = new Label("Register for Courses");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        Label instructionLabel = new Label("Select courses you want to register for:");
        instructionLabel.setStyle("-fx-font-size: 14px; -fx-text-fill: #7f8c8d;");

        ScrollPane scrollPane = new ScrollPane();
        VBox coursesBox = new VBox(10);
        coursesBox.setPadding(new Insets(15));
        coursesBox.setStyle("-fx-background-color: white; -fx-background-radius: 10;");

        List<CheckBox> courseCheckboxes = new ArrayList<>();

        for (Course course : availableCourses) {
            CheckBox cb = new CheckBox(course.getCode() + " - " + course.getName() + " (" + course.getCredits() + " credits)");
            cb.setUserData(course);

            // Check if already registered
            boolean isRegistered = registeredCourses.stream()
                    .anyMatch(regCourse -> regCourse.getCode().equals(course.getCode()));
            cb.setSelected(isRegistered);
            cb.setDisable(isRegistered);

            if (isRegistered) {
                cb.setText(cb.getText() + " [Already Registered]");
                cb.setStyle("-fx-text-fill: #27ae60;");
            }

            courseCheckboxes.add(cb);
            coursesBox.getChildren().add(cb);
        }

        scrollPane.setContent(coursesBox);
        scrollPane.setFitToWidth(true);
        scrollPane.setPrefHeight(250);

        HBox buttonBox = new HBox(10);
        buttonBox.setAlignment(Pos.CENTER);

        Button registerButton = new Button("Register Selected Courses");
        registerButton.setStyle("-fx-background-color: #3498db; -fx-text-fill: white; -fx-font-weight: bold;");
        registerButton.setOnAction(e -> {
            List<Course> selectedCourses = new ArrayList<>();
            for (CheckBox cb : courseCheckboxes) {
                if (cb.isSelected() && !cb.isDisabled()) {
                    selectedCourses.add((Course) cb.getUserData());
                }
            }

            if (selectedCourses.isEmpty()) {
                showAlert("No Selection", "Please select at least one course to register.", Alert.AlertType.WARNING);
            } else {
                registeredCourses.addAll(selectedCourses);
                saveRegisteredCourses();
                showAlert("Success", "Successfully registered for " + selectedCourses.size() + " course(s)!", Alert.AlertType.INFORMATION);
                showRegisterCoursePage(); // Refresh the page
            }
        });

        Button backButton = new Button("Back to Dashboard");
        backButton.setStyle("-fx-background-color: #95a5a6; -fx-text-fill: white; -fx-font-weight: bold;");
        backButton.setOnAction(e -> showDashboard());

        buttonBox.getChildren().addAll(registerButton, backButton);

        registerBox.getChildren().addAll(titleLabel, instructionLabel, scrollPane, buttonBox);

        Scene scene = new Scene(registerBox, 700, 600);
        primaryStage.setScene(scene);
    }

    private void showViewCoursesPage() {
        VBox viewBox = new VBox(20);
        viewBox.setPadding(new Insets(30));
        viewBox.setStyle("-fx-background-color: #ecf0f1;");

        Label titleLabel = new Label("My Registered Courses");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        TableView<Course> table = new TableView<>();
        table.setPrefHeight(350);

        TableColumn<Course, String> codeCol = new TableColumn<>("Course Code");
        codeCol.setCellValueFactory(new PropertyValueFactory<>("code"));
        codeCol.setPrefWidth(120);

        TableColumn<Course, String> nameCol = new TableColumn<>("Course Name");
        nameCol.setCellValueFactory(new PropertyValueFactory<>("name"));
        nameCol.setPrefWidth(300);

        TableColumn<Course, Integer> creditsCol = new TableColumn<>("Credits");
        creditsCol.setCellValueFactory(new PropertyValueFactory<>("credits"));
        creditsCol.setPrefWidth(80);

        TableColumn<Course, Void> actionCol = new TableColumn<>("Action");
        actionCol.setPrefWidth(100);
        actionCol.setCellFactory(param -> new TableCell<>() {
            private final Button deleteBtn = new Button("Delete");

            {
                deleteBtn.setStyle("-fx-background-color: #e74c3c; -fx-text-fill: white; -fx-font-size: 12px;");
                deleteBtn.setOnAction(e -> {
                    Course course = getTableView().getItems().get(getIndex());

                    Alert confirm = new Alert(Alert.AlertType.CONFIRMATION);
                    confirm.setTitle("Confirm Deletion");
                    confirm.setHeaderText("Delete Course Registration");
                    confirm.setContentText("Are you sure you want to unregister from " + course.getName() + "?");

                    Optional<ButtonType> result = confirm.showAndWait();
                    if (result.isPresent() && result.get() == ButtonType.OK) {
                        registeredCourses.remove(course);
                        saveRegisteredCourses();
                        getTableView().getItems().remove(course);
                        showAlert("Success", "Course unregistered successfully!", Alert.AlertType.INFORMATION);
                    }
                });
            }

            @Override
            protected void updateItem(Void item, boolean empty) {
                super.updateItem(item, empty);
                if (empty) {
                    setGraphic(null);
                } else {
                    setGraphic(deleteBtn);
                }
            }
        });

        table.getColumns().addAll(codeCol, nameCol, creditsCol, actionCol);
        table.getItems().addAll(registeredCourses);

        Label totalLabel = new Label("Total Registered Courses: " + registeredCourses.size());
        totalLabel.setStyle("-fx-font-size: 14px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        int totalCredits = registeredCourses.stream().mapToInt(Course::getCredits).sum();
        Label creditsLabel = new Label("Total Credits: " + totalCredits);
        creditsLabel.setStyle("-fx-font-size: 14px; -fx-font-weight: bold; -fx-text-fill: #27ae60;");

        Button backButton = new Button("Back to Dashboard");
        backButton.setStyle("-fx-background-color: #95a5a6; -fx-text-fill: white; -fx-font-weight: bold;");
        backButton.setOnAction(e -> showDashboard());

        HBox statsBox = new HBox(30);
        statsBox.setAlignment(Pos.CENTER);
        statsBox.getChildren().addAll(totalLabel, creditsLabel);

        viewBox.getChildren().addAll(titleLabel, table, statsBox, backButton);

        Scene scene = new Scene(viewBox, 700, 600);
        primaryStage.setScene(scene);
    }

    private void handleCloseRequest(WindowEvent event) {
        Alert alert = new Alert(Alert.AlertType.CONFIRMATION);
        alert.setTitle("Exit Confirmation");
        alert.setHeaderText("Are you sure you want to exit?");
        alert.setContentText("Any unsaved changes will be lost.");

        Optional<ButtonType> result = alert.showAndWait();
        if (result.isPresent() && result.get() == ButtonType.OK) {
            Platform.exit();
        } else {
            event.consume();
        }
    }

    private void showAlert(String title, String message, Alert.AlertType type) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }

    // File I/O Methods
    private void saveStudentData() {
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(STUDENT_DATA_FILE))) {
            oos.writeObject(currentStudent);
        } catch (IOException e) {
            showAlert("Error", "Failed to save student data: " + e.getMessage(), Alert.AlertType.ERROR);
        }
    }

    private void loadStudentData() {
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(STUDENT_DATA_FILE))) {
            currentStudent = (Student) ois.readObject();
        } catch (FileNotFoundException e) {
            // File doesn't exist yet, use default student
        } catch (IOException | ClassNotFoundException e) {
            showAlert("Error", "Failed to load student data: " + e.getMessage(), Alert.AlertType.ERROR);
        }
    }

    private void saveRegisteredCourses() {
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(COURSES_DATA_FILE))) {
            oos.writeObject(new ArrayList<>(registeredCourses));
        } catch (IOException e) {
            showAlert("Error", "Failed to save course data: " + e.getMessage(), Alert.AlertType.ERROR);
        }
    }

    private void loadRegisteredCourses() {
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(COURSES_DATA_FILE))) {
            registeredCourses = (List<Course>) ois.readObject();
        } catch (FileNotFoundException e) {
            // File doesn't exist yet, keep empty list
            registeredCourses = new ArrayList<>();
        } catch (IOException | ClassNotFoundException e) {
            showAlert("Error", "Failed to load course data: " + e.getMessage(), Alert.AlertType.ERROR);
            registeredCourses = new ArrayList<>();
        }
    }

    public static void main(String[] args) {
        launch(args);
    }
}
