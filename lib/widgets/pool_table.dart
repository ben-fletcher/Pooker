import 'package:flutter/material.dart';

class PoolTable extends StatelessWidget {
  const PoolTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        image: DecorationImage(
          image: AssetImage('assets/pool_table_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Top left pocket
          Positioned(
            top: 0,
            left: 0,
            child: _buildPocket(),
          ),
          // Top center pocket
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: _buildPocket(),
          ),
          // Top right pocket
          Positioned(
            top: 0,
            right: 0,
            child: _buildPocket(),
          ),
          // Bottom left pocket
          Positioned(
            bottom: 0,
            left: 0,
            child: _buildPocket(),
          ),
          // Bottom center pocket
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: _buildPocket(),
          ),
          // Bottom right pocket
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildPocket(),
          ),
        ],
      ),
    );
  }

  Widget _buildPocket() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}
