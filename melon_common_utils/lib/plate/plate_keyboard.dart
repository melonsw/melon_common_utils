import 'package:cloud/widgets/plate/keyboard_button.dart';
import 'package:cloud/widgets/plate/keyboard_controller.dart';
import 'package:cloud/widgets/plate/plate_datas.dart';
import 'package:cloud/widgets/plate/plate_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef PlateNumberChanged = void Function(int index, String value);

/// 中国车牌号输入键盘
class PlateKeyboard extends StatefulWidget {
  const PlateKeyboard({
    this.plateNumbers = const [],
    this.keyboardController,
    this.styles = PlateStyles.light,
    this.newEnergy = true,
    this.onChange,
    this.animationController,
    this.onComplete,
    this.onChangeSystem,
  });

  final List<String> plateNumbers;
  final KeyboardController keyboardController;
  final PlateStyles styles;
  final bool newEnergy;
  final PlateNumberChanged onChange;
  final AnimationController animationController;
  final VoidCallback onComplete;
  final VoidCallback onChangeSystem;

  @override
  _PlateKeyboardState createState() => _PlateKeyboardState();
}

class _PlateKeyboardState extends State<PlateKeyboard> {
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.decelerate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // int index = widget.keyboardController.cursorIndex;
    int index = widget.keyboardController.plateNumber.length;
    double childAspectRatio;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      childAspectRatio = 0 == index ? 3 / 4 : 2 / 3;
    } else {
      childAspectRatio = 0 == index ? 2 / 1 : 16 / 9;
    }
    return SlideTransition(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                ),
                onTap: () => widget.onComplete?.call(),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Text(
                      '切换系统键盘',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => widget.onChangeSystem?.call(),
                  ),
                  GestureDetector(
                    child: Text(
                      '完成',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => widget.onComplete?.call(),
                  ),
                ],
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 0,
                    color: widget.styles.keyboardBackgroundColor,
                  ),
                ),
                color: widget.styles.keyboardButtonColor,
              ),
            ),
            Container(
              color: widget.styles.keyboardBackgroundColor,
              padding: EdgeInsets.all(10),
              alignment: Alignment.bottomCenter,
              child: GridView.count(
                crossAxisCount: 0 == index ? 9 : 10,
                childAspectRatio: childAspectRatio,
                shrinkWrap: true,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: _buildKeys(),
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ),
      position: _offsetAnimation,
    );
  }

  List<Widget> _buildKeys() {
    List<Widget> keys = [];
    // int index = widget.keyboardController.cursorIndex;
    int index = widget.keyboardController.plateNumber.length;
    if (0 == index) {
      /// 省份
      provinces.forEach(
          (element) => keys.add(_buildKeyboardButton(element, 0 == index)));
    } else {
      /// 数字
      numbers.forEach(
          (element) => keys.add(_buildKeyboardButton(element, index > 1)));

      /// 字母 Q ~ P
      alphabets[0].forEach((element) {
        if (element != 'O') {
          keys.add(_buildKeyboardButton(element, true));
        } else if ('O' == element) {
          if (index < 5) {
            keys.add(_buildKeyboardButton(element, true));
          } else if (5 == index) {
            keys.add(_buildKeyboardButton(element, false));
          }
        }
      });
      if (index > 5) {
        keys.add(_buildKeyboardButton(specials[0], true));
      }

      /// 领
      keys.add(_buildKeyboardButton(specials[1], index >= 6));

      /// 字母 A ~ L
      alphabets[1].forEach(
          (element) => keys.add(_buildKeyboardButton(element, index > 0)));

      /// 警
      keys.add(_buildKeyboardButton(specials[2], index >= 6));

      /// 字母 Z ~ M
      alphabets[2].forEach(
          (element) => keys.add(_buildKeyboardButton(element, index > 0)));

      /// 港
      keys.add(_buildKeyboardButton(specials[3], index >= 6));

      /// 澳
      keys.add(_buildKeyboardButton(specials[4], index >= 6));
    }

    /// 退格
    keys.add(_buildBackspace());
    return keys;
  }

  Widget _buildKeyboardButton(String data, bool enable) {
    return KeyboardButton(
      child: Text(data),
      color: widget.styles.keyboardButtonColor,
      textColor: widget.styles.keyboardButtonTextColor,
      disabledColor: widget.styles.keyboardButtonDisabledColor,
      onPressed: enable
          ? () {
              // int index = widget.keyboardController.cursorIndex;
              int index = widget.keyboardController.plateNumber.length;
              if (index <= 7) {
                widget.onChange?.call(index, data);
                widget.keyboardController.cursorIndex++;
                setState(() {});
              }
            }
          : null,
    );
  }

  Widget _buildBackspace() {
    return KeyboardButton(
      child: Icon(
        Icons.backspace_outlined,
        size: 20,
        color: widget.styles.keyboardButtonTextColor,
      ),
      // Image(
      //   image: AssetImage('assets/images/backspace.png'),
      //   width: 40,
      //   height: 20,
      //   color: widget.styles.keyboardButtonTextColor,
      //   colorBlendMode: BlendMode.srcIn,
      // ),
      color: widget.styles.keyboardButtonColor,
      onPressed: () {
        // int index = widget.keyboardController.cursorIndex;
        int index = widget.keyboardController.plateNumber.length;
        if (index == 0) {
          index = 0;
        } else {
          index = index - 1;
        }
        widget.onChange?.call(index, '');
        if (index > 0) {
          widget.keyboardController.cursorIndex--;
        }
        setState(() {});
      },
    );
  }
}
