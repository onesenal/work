import sys
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QLabel, QLineEdit, QPushButton, QMessageBox, QListWidget, QSystemTrayIcon, QAction, QMenu, QStyle  # QStyle 추가
from PyQt5.QtCore import QTimer, Qt
from datetime import datetime, timedelta

class CertificateManager(QWidget):
    def __init__(self):
        super().__init__()
        self.certificates = []

        self.init_ui()
        self.start_alarm()
        self.create_system_tray_icon()

    def init_ui(self):
        self.setWindowTitle('Certificate Manager')
        self.setGeometry(100, 100, 400, 300)

        self.cert_name_label = QLabel('인증서 이름:')
        self.cert_name_input = QLineEdit()
        self.expire_date_label = QLabel('만료 날짜 (YYYY-MM-DD):')
        self.expire_date_input = QLineEdit()
        self.add_button = QPushButton('인증서 추가하기')
        self.add_button.clicked.connect(self.add_certificate)

        self.cert_list_label = QLabel('인증서 목록:')
        self.cert_list = QListWidget()

        vbox = QVBoxLayout()
        vbox.addWidget(self.cert_name_label)
        vbox.addWidget(self.cert_name_input)
        vbox.addWidget(self.expire_date_label)
        vbox.addWidget(self.expire_date_input)
        vbox.addWidget(self.add_button)
        vbox.addWidget(self.cert_list_label)
        vbox.addWidget(self.cert_list)

        self.setLayout(vbox)
        self.show()

        self.delete_button = QPushButton('인증서 삭제하기')
        self.delete_button.clicked.connect(self.delete_certificate)

        vbox.addWidget(self.delete_button)

    def delete_certificate(self):
        selected_items = self.cert_list.selectedItems()
        if not selected_items:
            QMessageBox.warning(self, 'Warning', '삭제할 항목을 선택하세요.')
            return

        for item in selected_items:
            cert_name = item.text().split(' - ')[0]  # 선택된 항목의 이름 가져오기
            for cert in self.certificates:
                if cert['name'] == cert_name:
                    self.certificates.remove(cert)
                    break

        self.update_certificate_list()

    def add_certificate(self):
        cert_name = self.cert_name_input.text()
        expire_date_str = self.expire_date_input.text()

        try:
            expire_date = datetime.strptime(expire_date_str, '%Y-%m-%d')
            today = datetime.now()

            if expire_date > today:
                self.certificates.append({'name': cert_name, 'expire_date': expire_date})
                QMessageBox.information(self, 'Success', '인증서가 추가되었습니다.')
                self.update_certificate_list()
                self.check_expiry(expire_date, cert_name)
            else:
                QMessageBox.warning(self, 'Error', '유효하지 않은 날짜입니다.')
        except ValueError:
            QMessageBox.warning(self, 'Error', '올바른 날짜 형식을 입력하세요 (YYYY-MM-DD).')

    def check_expiry(self, expire_date, cert_name):
        today = datetime.now()
        diff = expire_date - today

        days_before_expiry = [30, 20, 10, 5, 4, 3, 2, 1]  # 원하는 날짜 설정
        if diff.days in days_before_expiry:
            QMessageBox.warning(self, 'Certificate Expiry Alert',
                                f'{cert_name} 인증서의 만료 날짜가 {diff.days}일 남았습니다.')

    def update_certificate_list(self):
        self.cert_list.clear()
        for cert in self.certificates:
            self.cert_list.addItem(f"{cert['name']} - 만료일: {cert['expire_date'].strftime('%Y-%m-%d')} ")

    def start_alarm(self):
        self.timer = QTimer()
        self.timer.timeout.connect(self.check_certificates)
        self.timer.start(24 * 60 * 60 * 1000)  # 24시간(하루)마다 타이머 실행 (ms 단위)

    def check_certificates(self):
        for cert in self.certificates:
            expire_date = cert['expire_date']
            cert_name = cert['name']
            self.check_expiry(expire_date, cert_name)

    def create_system_tray_icon(self):
        self.tray_icon = QSystemTrayIcon(self)
        self.tray_icon.setIcon(self.style().standardIcon(QStyle.SP_ComputerIcon))  # 수정된 부분: QStyle.SP_ComputerIcon 사용

        show_action = QAction("Show", self)
        show_action.triggered.connect(self.show)
        
        quit_action = QAction("Quit", self)
        quit_action.triggered.connect(self.close)

        tray_menu = QMenu()  # QMenu를 생성하여 아이콘에 연결합니다.
        tray_menu.addAction(show_action)
        tray_menu.addAction(quit_action)

        self.tray_icon.setContextMenu(tray_menu)
        self.tray_icon.show()

    def closeEvent(self, event):
        event.ignore()
        self.hide()
        self.tray_icon.showMessage(
            "Certificate Manager",
            "프로그램이 여전히 실행 중입니다. 트레이 아이콘을 클릭하여 화면에 표시할 수 있습니다.",
            QSystemTrayIcon.Information,
            2000
        )

def main():
    app = QApplication(sys.argv)
    ex = CertificateManager()
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()