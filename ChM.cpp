#include <iostream>
#include <fstream>
#include <vector>
#include <random>
#include <cmath>
#include <iomanip>
#include <windows.h>

// Класс для работы с векторами
class Vector {
private:
    std::vector<double> data;  // Вектор для хранения элементов

public:
    // Конструкторы
    Vector() = default;  // Конструктор по умолчанию
    explicit Vector(size_t size) : data(size, 0.0) {}  // Конструктор с заданным размером
    Vector(const std::vector<double>& values) : data(values) {}  // Конструктор из существующего вектора

    // Загрузка вектора из файла
    void load_from_file(const std::string& filename) {
        std::ifstream input_file(filename);
        if (!input_file.is_open()) {
            throw std::runtime_error("Не удалось открыть файл: " + filename);
        }
        data.clear();  // Очищаем текущие данные
        double value;
        while (input_file >> value) {
            data.push_back(value);  // Читаем значения из файла
        }
        input_file.close();
    }

    // Ввод вектора с консоли
    void input_from_console() {
        size_t size;
        std::cout << "Введите размер вектора: ";
        std::cin >> size;
        data.resize(size);  // Изменяем размер вектора
        std::cout << "Введите " << size << " значений:\n";
        for (size_t i = 0; i < size; ++i) {
            std::cin >> data[i];  // Заполняем вектор значениями с консоли
        }
    }

    // Генерация случайного вектора
    void generate_random(double min_val, double max_val) {
        std::random_device random_device;
        std::mt19937 generator(random_device());
        std::uniform_real_distribution<double> distribution(min_val, max_val);
        for (double& element : data) {
            element = distribution(generator);  // Заполняем случайными значениями
        }
    }

    // Сохранение вектора в файл
    void save_to_file(const std::string& filename) const {
        std::ofstream output_file(filename);
        if (!output_file.is_open()) {
            throw std::runtime_error("Не удалось открыть файл: " + filename);
        }
        for (const double& element : data) {
            output_file << element << " ";  // Записываем элементы в файл
        }
        output_file << '\n';
        output_file.close();
    }

    // Вывод вектора на консоль
    void display() const {
        for (const double& element : data) {
            std::cout << element << " ";  // Выводим элементы через пробел
        }
        std::cout << '\n';
    }

    // Оператор сложения векторов
    Vector operator+(const Vector& other) const {
        if (data.size() != other.data.size()) {
            throw std::runtime_error("Размеры векторов не совпадают");
        }
        Vector result(data.size());
        for (size_t i = 0; i < data.size(); ++i) {
            result.data[i] = data[i] + other.data[i];  // Поэлементное сложение
        }
        return result;
    }

    // Оператор вычитания векторов
    Vector operator-(const Vector& other) const {
        if (data.size() != other.data.size()) {
            throw std::runtime_error("Размеры векторов не совпадают");
        }
        Vector result(data.size());
        for (size_t i = 0; i < data.size(); ++i) {
            result.data[i] = data[i] - other.data[i];  // Поэлементное вычитание
        }
        return result;
    }

    // Скалярное произведение векторов
    double dot_product(const Vector& other) const {
        if (data.size() != other.data.size()) {
            throw std::runtime_error("Размеры векторов не совпадают");
        }
        double result = 0.0;
        for (size_t i = 0; i < data.size(); ++i) {
            result += data[i] * other.data[i];  // Сумма произведений элементов
        }
        return result;
    }

    // Вычисление максимальной нормы (максимум модулей элементов)
    double max_norm() const {
        double max_value = 0.0;
        for (const double& element : data) {
            max_value = max(max_value, std::abs(element));  // Ищем максимальный модуль
        }
        return max_value;
    }

    // Оператор доступа к элементу по индексу (индексация с 0)
    double& operator[](size_t index) {
        if (index >= data.size()) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return data[index];
    }

    // Константный оператор доступа к элементу по индексу (индексация с 0)
    const double& operator[](size_t index) const {
        if (index >= data.size()) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return data[index];
    }

    // Оператор доступа к элементу по индексу (индексация с 1)
    double& operator()(size_t index) {
        if (index < 1 || index > data.size()) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return data[index - 1];
    }

    // Константный оператор доступа к элементу по индексу (индексация с 1)
    const double& operator()(size_t index) const {
        if (index < 1 || index > data.size()) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return data[index - 1];
    }

    // Получение размера вектора
    size_t length() const { return data.size(); }

    // Изменение размера вектора
    void set_size(size_t new_size, double default_value = 0.0) {
        data.resize(new_size, default_value);  // Изменяем размер с заполнением значением по умолчанию
    }
};

// Класс для работы с трехдиагональными матрицами
class TridiagonalMatrix {
private:
    Vector lower_diagonal;  // Нижняя диагональ (под главной)
    Vector main_diagonal;   // Главная диагональ
    Vector upper_diagonal;  // Верхняя диагональ (над главной)

public:
    // Конструкторы
    TridiagonalMatrix() = default;  // Конструктор по умолчанию
    TridiagonalMatrix(const Vector& lower, const Vector& main, const Vector& upper)
        : lower_diagonal(lower), main_diagonal(main), upper_diagonal(upper) {
        // Проверка согласованности размеров диагоналей
        if (lower_diagonal.length() != main_diagonal.length() - 1 ||
            upper_diagonal.length() != main_diagonal.length() - 1) {
            throw std::runtime_error("Недопустимые размеры диагоналей");
        }
    }

    // Загрузка матрицы из файла
    void load_from_file(const std::string& filename) {
        std::ifstream input_file(filename);
        if (!input_file.is_open()) {
            throw std::runtime_error("Не удалось открыть файл: " + filename);
        }
        size_t matrix_size;
        input_file >> matrix_size;  // Читаем размер матрицы
        // Устанавливаем размеры диагоналей
        lower_diagonal.set_size(matrix_size - 1);
        main_diagonal.set_size(matrix_size);
        upper_diagonal.set_size(matrix_size - 1);

        // Читаем элементы нижней диагонали
        for (size_t i = 0; i < matrix_size - 1; ++i) {
            input_file >> lower_diagonal[i];
        }
        // Читаем элементы главной диагонали
        for (size_t i = 0; i < matrix_size; ++i) {
            input_file >> main_diagonal[i];
        }
        // Читаем элементы верхней диагонали
        for (size_t i = 0; i < matrix_size - 1; ++i) {
            input_file >> upper_diagonal[i];
        }
        input_file.close();
    }

    // Ввод матрицы с консоли
    void input_from_console() {
        size_t matrix_size;
        std::cout << "Введите размер матрицы: ";
        std::cin >> matrix_size;
        // Устанавливаем размеры диагоналей
        lower_diagonal.set_size(matrix_size - 1);
        main_diagonal.set_size(matrix_size);
        upper_diagonal.set_size(matrix_size - 1);

        // Ввод элементов нижней диагонали
        std::cout << "Введите " << matrix_size - 1 << " элементов нижней диагонали: ";
        for (size_t i = 0; i < matrix_size - 1; ++i) {
            std::cin >> lower_diagonal[i];
        }
        // Ввод элементов главной диагонали
        std::cout << "Введите " << matrix_size << " элементов главной диагонали: ";
        for (size_t i = 0; i < matrix_size; ++i) {
            std::cin >> main_diagonal[i];
        }
        // Ввод элементов верхней диагонали
        std::cout << "Введите " << matrix_size - 1 << " элементов верхней диагонали: ";
        for (size_t i = 0; i < matrix_size - 1; ++i) {
            std::cin >> upper_diagonal[i];
        }
    }

    // Генерация случайной трехдиагональной матрицы
    void generate_random(double min_val, double max_val) {
        lower_diagonal.generate_random(min_val, max_val);
        main_diagonal.generate_random(min_val, max_val);
        upper_diagonal.generate_random(min_val, max_val);
    }

    // Сохранение матрицы в файл
    void save_to_file(const std::string& filename) const {
        std::ofstream output_file(filename);
        if (!output_file.is_open()) {
            throw std::runtime_error("Не удалось открыть файл: " + filename);
        }
        output_file << main_diagonal.length() << '\n';  // Записываем размер матрицы

        // Записываем нижнюю диагональ
        for (size_t i = 0; i < lower_diagonal.length(); ++i) {
            output_file << lower_diagonal[i] << " ";
        }
        output_file << '\n';

        // Записываем главную диагональ
        for (size_t i = 0; i < main_diagonal.length(); ++i) {
            output_file << main_diagonal[i] << " ";
        }
        output_file << '\n';

        // Записываем верхнюю диагональ
        for (size_t i = 0; i < upper_diagonal.length(); ++i) {
            output_file << upper_diagonal[i] << " ";
        }
        output_file << '\n';
        output_file.close();
    }

    // Вывод матрицы на консоль в виде полноценной матрицы
    void display() const {
        size_t matrix_size = main_diagonal.length();
        for (size_t row = 1; row <= matrix_size; ++row) {
            for (size_t col = 1; col <= matrix_size; ++col) {
                if (col == row - 1 && row > 1) {
                    std::cout << get_lower_element(row) << " ";  // Элемент нижней диагонали
                }
                else if (col == row) {
                    std::cout << get_main_element(row) << " ";   // Элемент главной диагонали
                }
                else if (col == row + 1 && row < matrix_size) {
                    std::cout << get_upper_element(row) << " ";  // Элемент верхней диагонали
                }
                else {
                    std::cout << "0 ";  // Нулевой элемент вне диагоналей
                }
            }
            std::cout << '\n';
        }
    }

    // Умножение матрицы на вектор
    Vector operator*(const Vector& vector) const {
        if (vector.length() != main_diagonal.length()) {
            throw std::runtime_error("Размеры вектора и матрицы не совпадают");
        }
        size_t matrix_size = main_diagonal.length();
        Vector result(matrix_size);

        // Первый элемент результата
        result(1) = get_main_element(1) * vector(1) + get_upper_element(1) * vector(2);

        // Промежуточные элементы результата
        for (size_t i = 2; i <= matrix_size - 1; ++i) {
            result(i) = get_lower_element(i) * vector(i - 1) +
                get_main_element(i) * vector(i) +
                get_upper_element(i) * vector(i + 1);
        }

        // Последний элемент результата
        result(matrix_size) = get_lower_element(matrix_size) * vector(matrix_size - 1) +
            get_main_element(matrix_size) * vector(matrix_size);

        return result;
    }

    // Получение размера матрицы
    size_t size() const { return main_diagonal.length(); }

    // Методы доступа к элементам матрицы (константные версии)
    double get_lower_element(size_t row) const {
        if (row < 2 || row > main_diagonal.length()) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return lower_diagonal[row - 2];  // Индексация с 0 для нижней диагонали
    }

    double get_main_element(size_t row) const {
        if (row < 1 || row > main_diagonal.length()) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return main_diagonal[row - 1];  // Индексация с 0 для главной диагонали
    }

    double get_upper_element(size_t row) const {
        if (row < 1 || row > main_diagonal.length() - 1) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return upper_diagonal[row - 1];  // Индексация с 0 для верхней диагонали
    }

    // Методы доступа к элементам матрицы (неконстантные версии)
    double& get_lower_element(size_t row) {
        if (row < 2 || row > main_diagonal.length()) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return lower_diagonal[row - 2];
    }

    double& get_main_element(size_t row) {
        if (row < 1 || row > main_diagonal.length()) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return main_diagonal[row - 1];
    }

    double& get_upper_element(size_t row) {
        if (row < 1 || row > main_diagonal.length() - 1) {
            throw std::out_of_range("Индекс вне диапазона");
        }
        return upper_diagonal[row - 1];
    }

    // Решение системы уравнений методом прогонки
    Vector solve_sweep_method(const Vector& right_side, bool show_steps = true) const {
        if (right_side.length() != main_diagonal.length()) {
            throw std::runtime_error("Размеры вектора и матрицы не совпадают");
        }

        size_t matrix_size = main_diagonal.length();
        Vector solution(matrix_size);  // Вектор для решения
        Vector m_coeffs(matrix_size + 1);  // Коэффициенты m
        Vector l_coeffs(matrix_size + 1);  // Коэффициенты l

        if (show_steps) {
            std::cout << "\n Метод прогонки \n";
        }

        // Прямой ход метода прогонки

        // Проверка первого элемента главной диагонали
        if (std::abs(get_main_element(1)) < 1e-15) {
            throw std::runtime_error("Элемент главной диагонали слишком мал");
        }

        // Вычисление первых прогоночных коэффициентов
        m_coeffs(2) = get_upper_element(1) / get_main_element(1);
        l_coeffs(2) = right_side(1) / get_main_element(1);

        if (show_steps) {
            std::cout << "Шаг 1: m[2]=" << m_coeffs(2) << ", l[2]=" << l_coeffs(2) << '\n';
        }

        // Вычисление прогоночных коэффициентов для промежуточных строк
        for (size_t i = 2; i <= matrix_size - 1; ++i) {
            double denominator = get_main_element(i) - get_lower_element(i) * m_coeffs(i);
            if (std::abs(denominator) < 1e-15) {
                throw std::runtime_error("Знаменатель слишком мал");
            }
            m_coeffs(i + 1) = get_upper_element(i) / denominator;
            l_coeffs(i + 1) = (right_side(i) - get_lower_element(i) * l_coeffs(i)) / denominator;

            if (show_steps) {
                std::cout << "Шаг " << i << ": m[" << i + 1 << "]=" << m_coeffs(i + 1)
                    << ", l[" << i + 1 << "]=" << l_coeffs(i + 1) << '\n';
            }
        }

        // Вычисление последнего элемента решения
        double last_denominator = get_main_element(matrix_size) - get_lower_element(matrix_size) * m_coeffs(matrix_size);
        if (std::abs(last_denominator) < 1e-15) {
            throw std::runtime_error("Знаменатель слишком мал");
        }
        solution(matrix_size) = (right_side(matrix_size) - get_lower_element(matrix_size) * l_coeffs(matrix_size)) / last_denominator;

        if (show_steps) {
            std::cout << "Шаг " << matrix_size << ": x[" << matrix_size << "]=" << solution(matrix_size) << '\n';
        }

        // Обратный ход метода прогонки
        if (show_steps) {
            std::cout << "Обратный ход:\n";
        }

        for (int i = matrix_size - 1; i >= 1; --i) {
            solution(i) = l_coeffs(i + 1) - m_coeffs(i + 1) * solution(i + 1);
            if (show_steps) {
                std::cout << "x[" << i << "]=" << solution(i) << " ";
            }
        }

        if (show_steps) {
            std::cout << '\n';
        }

        return solution;
    }
};

// Функция для вычисления погрешностей решения
void compute_solution_errors(const TridiagonalMatrix& matrix, const Vector& exact_solution,
    double& absolute_error, double& relative_error, bool show_details = false) {
    // Вычисляем правую часть системы для точного решения
    Vector right_side = matrix * exact_solution;
    // Решаем систему методом прогонки
    Vector computed_solution = matrix.solve_sweep_method(right_side, show_details);
    // Вычисляем вектор ошибки
    Vector error_vector = computed_solution - exact_solution;

    // Вычисляем абсолютную погрешность (максимальная норма ошибки)
    absolute_error = error_vector.max_norm();
    relative_error = 0.0;

    // Порог для избежания деления на ноль
    double epsilon = std::sqrt(std::numeric_limits<double>::epsilon());

    // Вычисляем относительную погрешность
    for (size_t i = 1; i <= exact_solution.length(); ++i) {
        double exact_value = std::abs(exact_solution(i));
        double error_value = std::abs(error_vector(i));
        double relative_component = error_value;

        // Если точное значение достаточно велико, вычисляем относительную ошибку
        if (exact_value > epsilon) {
            relative_component /= exact_value;
        }

        // Ищем максимальную относительную ошибку
        relative_error = max(relative_error, relative_component);
    }
}

// Тестирование на хорошо обусловленных матрицах
void test_well_conditioned_matrices() {
    std::vector<size_t> test_sizes = { 16, 32, 64, 128, 256, 512, 1024, 2048, 4096 };
    std::cout << "\n Хорошо обусловленные матрицы \n";
    std::cout << "Размер\tАбс. Погрешность\tОтн. Погрешность\n";

    for (size_t matrix_size : test_sizes) {
        // Создаем диагонали матрицы
        Vector lower_diag(matrix_size - 1), main_diag(matrix_size), upper_diag(matrix_size - 1);
        std::random_device random_device;
        std::mt19937 generator(random_device());
        std::uniform_real_distribution<double> distribution(-10.0, 10.0);

        // Заполняем нижнюю и верхнюю диагонали случайными значениями
        for (size_t i = 0; i < matrix_size - 1; ++i) {
            lower_diag[i] = distribution(generator);
            upper_diag[i] = distribution(generator);
        }

        // Создаем хорошо обусловленную главную диагональ
        std::uniform_real_distribution<double> bias_distribution(1.0, 10.0);
        main_diag[0] = std::abs(upper_diag[0]) * 100.0 + bias_distribution(generator);
        for (size_t i = 1; i < matrix_size - 1; ++i) {
            main_diag[i] = (std::abs(lower_diag[i]) + std::abs(upper_diag[i])) * 100.0 + bias_distribution(generator);
        }
        main_diag[matrix_size - 1] = std::abs(lower_diag[matrix_size - 2]) * 100.0 + bias_distribution(generator);

        // Создаем матрицу и точное решение
        TridiagonalMatrix matrix(lower_diag, main_diag, upper_diag);
        Vector exact_solution(matrix_size);
        std::uniform_real_distribution<double> solution_distribution(-10.0, 10.0);

        // Генерируем случайное точное решение
        for (size_t i = 0; i < matrix_size; ++i) {
            exact_solution(i + 1) = solution_distribution(generator);
        }

        // Вычисляем погрешности
        double absolute_error, relative_error;
        compute_solution_errors(matrix, exact_solution, absolute_error, relative_error, false);

        // Выводим результаты
        std::cout << std::setw(6) << matrix_size
            << std::setw(14) << std::scientific << std::setprecision(2) << absolute_error
            << std::setw(14) << std::scientific << std::setprecision(2) << relative_error << '\n';
    }
}

// Тестирование на плохо обусловленных матрицах
void test_ill_conditioned_matrices() {
    std::vector<size_t> test_sizes = { 16, 32, 64, 128, 256, 512, 1024, 2048, 4096 };
    std::cout << "\n Плохо обусловленные матрицы \n";
    std::cout << "Размер\tАбс. Погрешность\tОтн. Погрешность\n";

    for (size_t matrix_size : test_sizes) {
        // Создаем диагонали матрицы
        Vector lower_diag(matrix_size - 1), main_diag(matrix_size), upper_diag(matrix_size - 1);
        std::random_device random_device;
        std::mt19937 generator(random_device());
        std::uniform_real_distribution<double> distribution(-10.0, 10.0);

        // Заполняем нижнюю и верхнюю диагонали случайными значениями
        for (size_t i = 0; i < matrix_size - 1; ++i) {
            lower_diag[i] = distribution(generator);
            upper_diag[i] = distribution(generator);
        }

        // Создаем плохо обусловленную главную диагональ
        std::uniform_real_distribution<double> bias_distribution(1.0, 10.0);
        main_diag[0] = std::abs(upper_diag[0]) * 0.01 + bias_distribution(generator);
        for (size_t i = 1; i < matrix_size - 1; ++i) {
            std::uniform_real_distribution<double> small_distribution(0.001, 0.01);
            main_diag[i] = (std::abs(lower_diag[i]) + std::abs(upper_diag[i])) * 0.01 + small_distribution(generator);
        }
        main_diag[matrix_size - 1] = std::abs(lower_diag[matrix_size - 2]) * 0.01 + bias_distribution(generator);

        // Создаем матрицу и точное решение
        TridiagonalMatrix matrix(lower_diag, main_diag, upper_diag);
        Vector exact_solution(matrix_size);
        std::uniform_real_distribution<double> solution_distribution(-10.0, 10.0);

        // Генерируем случайное точное решение
        for (size_t i = 0; i < matrix_size; ++i) {
            exact_solution(i + 1) = solution_distribution(generator);
        }

        // Вычисляем погрешности
        double absolute_error, relative_error;
        compute_solution_errors(matrix, exact_solution, absolute_error, relative_error, false);

        // Выводим результаты
        std::cout << std::setw(6) << matrix_size
            << std::setw(14) << std::scientific << std::setprecision(2) << absolute_error
            << std::setw(14) << std::scientific << std::setprecision(2) << relative_error << '\n';
    }
}

// Запуск тестов зависимости погрешности от размера матрицы
void run_size_dependence_tests() {
    test_well_conditioned_matrices();
    test_ill_conditioned_matrices();
}

// Проведение одиночного эксперимента
void run_single_experiment(size_t matrix_size) {
    std::random_device random_device;
    std::mt19937 generator(random_device());
    std::uniform_real_distribution<double> distribution(-10.0, 10.0);

    // Создаем диагонали матрицы
    Vector lower_diag(matrix_size - 1), main_diag(matrix_size), upper_diag(matrix_size - 1);

    // Заполняем нижнюю и верхнюю диагонали случайными значениями
    for (size_t i = 0; i < matrix_size - 1; ++i) {
        lower_diag[i] = distribution(generator);
        upper_diag[i] = distribution(generator);
    }

    // Создаем хорошо обусловленную главную диагональ
    std::uniform_real_distribution<double> bias_distribution(1.0, 10.0);
    main_diag[0] = std::abs(upper_diag[0]) * 100.0 + bias_distribution(generator);
    for (size_t i = 1; i < matrix_size - 1; ++i) {
        main_diag[i] = (std::abs(lower_diag[i]) + std::abs(upper_diag[i])) * 100.0 + bias_distribution(generator);
    }
    main_diag[matrix_size - 1] = std::abs(lower_diag[matrix_size - 2]) * 100.0 + bias_distribution(generator);

    // Создаем матрицу и точное решение
    TridiagonalMatrix matrix(lower_diag, main_diag, upper_diag);
    Vector exact_solution(matrix_size);
    std::uniform_real_distribution<double> solution_distribution(-10.0, 10.0);

    // Генерируем случайное точное решение
    for (size_t i = 0; i < matrix_size; ++i) {
        exact_solution(i + 1) = solution_distribution(generator);
    }

    // Выводим матрицу и точное решение
    matrix.display();
    std::cout << '\n';
    exact_solution.display();

    // Вычисляем погрешности 
    double absolute_error, relative_error;
    compute_solution_errors(matrix, exact_solution, absolute_error, relative_error, true);

    // Выводим результаты
    std::cout << "\nрезультаты:\n";
    std::cout << "Метод прогонки:\n";
    std::cout << "  Абсолютная погрешность: " << absolute_error << '\n';
    std::cout << "  Относительная погрешность: " << relative_error << '\n';

    // Демонстрируем решение
    Vector right_side = matrix * exact_solution;
    Vector computed_solution = matrix.solve_sweep_method(right_side, false);

    std::cout << "\nТочное решение: ";
    exact_solution.display();
    std::cout << "Решение методом прогонки: ";
    computed_solution.display();
}

// Главная функция программы
int main() {
    // Устанавливаем кодировку консоли для поддержки русского языка
    SetConsoleOutputCP(1251);

    std::cout << "Решение систем с трехдиагональной матрицей\n";
    std::cout << "1. Ручной ввод\n";
    std::cout << "2. Ввод из файла\n";
    std::cout << "3. Тест зависимости от размера\n";
    std::cout << "4. Одиночный эксперимент\n";
    std::cout << "Выберите опцию: ";

    int user_choice;
    std::cin >> user_choice;

    if (user_choice == 1 || user_choice == 2) {
        TridiagonalMatrix matrix;
        Vector right_side;

        if (user_choice == 1) {
            // Ручной ввод данных
            std::cout << "Введите матрицу (индексация с 1):\n";
            matrix.input_from_console();
            std::cout << "Введите правую часть системы:\n";
            right_side.input_from_console();
        }
        else {
            // Ввод данных из файлов
            std::string matrix_filename, rhs_filename;
            std::cout << "Введите имя файла с матрицей: ";
            std::cin >> matrix_filename;
            matrix.load_from_file(matrix_filename);

            std::cout << "Введите имя файла с правой частью: ";
            std::cin >> rhs_filename;
            right_side.load_from_file(rhs_filename);

            // Проверка согласованности размеров
            if (right_side.length() != matrix.size()) {
                std::cout << "Ошибка: размер правой части не совпадает с размером матрицы!\n";
                return 1;
            }
        }

        // Вывод введенных данных
        std::cout << "\nМатрица:\n";
        matrix.display();
        std::cout << "\nПравая часть: ";
        right_side.display();

        // Решение системы и вывод результата
        std::cout << "\nРешение методом прогонки:\n";
        Vector solution = matrix.solve_sweep_method(right_side, true);
        std::cout << "\nРешение методом прогонки: ";
        solution.display();

        // Сохранение результатов в файл
        std::cout << "\nСохранить результаты в файл? (y/n): ";
        char save_choice;
        std::cin >> save_choice;

        if (save_choice == 'y' || save_choice == 'Y') {
            std::string output_filename;
            std::cout << "Введите имя файла для сохранения: ";
            std::cin >> output_filename;

            std::ofstream output_file(output_filename);
            if (output_file.is_open()) {
                // Сохранение матрицы
                output_file << "Матрица:\n";
                output_file << "Размер: " << matrix.size() << "\n";

                // Сохранение диагоналей через прямое обращение к данным
                output_file << "Нижняя диагональ: ";
                for (size_t i = 0; i < matrix.size() - 1; ++i) {
                    output_file << matrix.get_lower_element(i + 2) << " ";
                }
                output_file << "\nГлавная диагональ: ";
                for (size_t i = 0; i < matrix.size(); ++i) {
                    output_file << matrix.get_main_element(i + 1) << " ";
                }
                output_file << "\nВерхняя диагональ: ";
                for (size_t i = 0; i < matrix.size() - 1; ++i) {
                    output_file << matrix.get_upper_element(i + 1) << " ";
                }

                // Сохранение правой части
                output_file << "\n\nПравая часть: ";
                for (size_t i = 1; i <= right_side.length(); ++i) {
                    output_file << right_side(i) << " ";
                }

                // Сохранение решения
                output_file << "\n\nРешение методом прогонки: ";
                for (size_t i = 1; i <= solution.length(); ++i) {
                    output_file << solution(i) << " ";
                }

                output_file.close();
                std::cout << "Результаты сохранены в файл: " << output_filename << "\n";
            }
        }
    }
    else if (user_choice == 3) {
        // Запуск тестов зависимости от размера
        run_size_dependence_tests();
    }
    else if (user_choice == 4) {
        // Проведение одиночного эксперимента
        size_t experiment_size;
        std::cout << "Введите размер матрицы: ";
        std::cin >> experiment_size;
        run_single_experiment(experiment_size);
    }
    else {
        std::cout << "Неверная опция!\n";
    }

    // Ожидание нажатия клавиши перед завершением
    std::cin.ignore();
    std::cin.get();
    return 0;
}